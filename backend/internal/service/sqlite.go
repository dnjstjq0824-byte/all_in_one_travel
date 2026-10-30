package service

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	_ "modernc.org/sqlite"
)

var ErrConflict = errors.New("concurrent update; retry the request")

// The snapshot is the transaction unit. Revision compare-and-swap prevents lost
// updates between server processes; every read/write refreshes its local snapshot.
func NewSQLiteServiceContainer(store *data.SeedStore, path string) (*ServiceContainer, error) {
	if path == "" { return nil, fmt.Errorf("database path is required") }
	abs, err := filepath.Abs(path)
	if err != nil { return nil, err }
	if err := os.MkdirAll(filepath.Dir(abs),0700); err != nil { return nil,err }
	db,err := sql.Open("sqlite",filepath.ToSlash(abs))
	if err != nil { return nil,err }
	db.SetMaxOpenConns(1)
	s := NewServiceContainer(store)
	s.database = db
	fail := func(err error) (*ServiceContainer,error) { db.Close(); return nil,err }
	for _,statement := range []string{"PRAGMA busy_timeout=5000","PRAGMA journal_mode=WAL","PRAGMA synchronous=FULL"} {
		if _,err:=db.Exec(statement);err!=nil { return fail(err) }
	}
	var version int
	if err:=db.QueryRow("PRAGMA user_version").Scan(&version);err!=nil { return fail(err) }
	if version>1 { return fail(fmt.Errorf("unsupported database schema %d",version)) }
	tx,err:=db.Begin()
	if err!=nil { return fail(err) }
	defer tx.Rollback()
	if _,err:=tx.Exec("CREATE TABLE IF NOT EXISTS app_state (id INTEGER PRIMARY KEY CHECK(id=1), revision INTEGER NOT NULL, payload BLOB NOT NULL)");err!=nil { return fail(err) }
	body,err:=json.Marshal(savedState{Version:1,Trips:store.Trips,Reviews:store.Reviews})
	if err!=nil { return fail(err) }
	if _,err:=tx.Exec("INSERT INTO app_state(id,revision,payload) VALUES(1,1,?) ON CONFLICT(id) DO NOTHING",body);err!=nil { return fail(err) }
	if _,err:=tx.Exec("PRAGMA user_version=1");err!=nil { return fail(err) }
	if err:=tx.Commit();err!=nil { return fail(err) }
	if err:=s.refreshState();err!=nil { return fail(err) }
	return s,nil
}

func (s *ServiceContainer) refreshState() error {
	if s.database==nil { return nil }
	var body []byte
	var revision int64
	if err:=s.database.QueryRow("SELECT revision,payload FROM app_state WHERE id=1").Scan(&revision,&body);err!=nil { return err }
	if revision==s.stateRevision { return nil }
	var state savedState
	if err:=json.Unmarshal(body,&state);err!=nil { return err }
	if state.Version!=1 || state.Trips==nil || state.Reviews==nil { return fmt.Errorf("invalid database state") }
	s.Store.Trips,s.Store.Reviews,s.stateRevision=state.Trips,state.Reviews,revision
	return nil
}

func (s *ServiceContainer) writeDatabase(trips map[string]model.Trip,reviews map[string][]model.Review) error {
	body,err:=json.Marshal(savedState{Version:1,Trips:trips,Reviews:reviews})
	if err!=nil { return err }
	result,err:=s.database.Exec("UPDATE app_state SET payload=?,revision=revision+1 WHERE id=1 AND revision=?",body,s.stateRevision)
	if err!=nil { return err }
	n,err:=result.RowsAffected()
	if err!=nil { return err }
	if n!=1 { return ErrConflict }
	s.stateRevision++
	return nil
}

// Backup creates a consistent SQLite snapshot, including committed WAL data.
// SQLite refuses an existing nonempty target rather than overwriting a backup.
func (s *ServiceContainer) Backup(path string) error {
	if s.database==nil { return fmt.Errorf("SQLite storage is not enabled") }
	if _,err:=os.Stat(path);err==nil { return fmt.Errorf("backup target already exists") }
	if err:=os.MkdirAll(filepath.Dir(path),0700);err!=nil { return err }
	_,err:=s.database.Exec("VACUUM INTO ?",filepath.ToSlash(path))
	return err
}

func (s *ServiceContainer) Close() error {
	if s.database!=nil { return s.database.Close() }
	return nil
}
