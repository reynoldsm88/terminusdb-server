:- module(config,[
              server/1,
              server_name/1,
              server_port/1,
              public_url/1,
              worker_amount/1,
              max_transaction_retries/1,
              index_path/1,
              default_database_path/1,
              jwt_public_key_path/1,
              jwt_public_key_id/1,
              registry_path/1,
              console_base_url/1,
              tmp_path/1,
              server_worker_options/1,
              http_options/1,
              max_journal_queue_length/1
          ]).

:- use_module(core(util/utils)).


server_name(Value) :-
    getenv_default('TERMINUSDB_SERVER_NAME', 'http://localhost', Value).

server_port(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_PORT', 6363, Value).

public_url(Value) :-
    getenv_default('TERMINUSDB_SERVER_PUBLIC_URL', 'http://localhost:6363', Value).

worker_amount(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_WORKERS', 8, Value).

max_transaction_retries(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_MAX_TRANSACTION_RETRIES', 3, Value).

index_path(Value) :-
    once(expand_file_search_path(config('index.html'), Path)),
    getenv_default('TERMINUSDB_SERVER_INDEX_PATH', Path, Value).

default_database_path(Value) :-
    once(expand_file_search_path(terminus_home(storage/db), Path)),
    getenv_default('TERMINUSDB_SERVER_DB_PATH', Path, Value).

jwt_public_key_path(Value) :-
    getenv_default('TERMINUSDB_SERVER_JWT_PUBLIC_KEY_PATH', '', Value).

jwt_public_key_id(Value) :-
    getenv_default('TERMINUSDB_SERVER_JWT_PUBLIC_KEY_ID', '', Value).

console_base_url(Value) :-
    getenv_default('TERMINUSDB_CONSOLE_BASE_URL', 'https://unpkg.com/@terminusdb/terminusdb-console@2.0.2/console/dist/', Value).

registry_path(Value) :-
    once(expand_file_search_path(plugins('registry.pl'), Path)),
    getenv_default('TERMINUSDB_SERVER_REGISTRY_PATH', Path, Value).

tmp_path(Value) :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/tmp',TmpPathRelative),
    getenv_default('TERMINUSDB_SERVER_TMP_PATH', TmpPathRelative, Value).


server(Server) :-
    server_name(Name),
    server_port(Port),
    atomic_list_concat([Name,':',Port],Server).

server_worker_options([]).

http_options([]).

% this number can never be less than 4 or bad things will happen.
max_journal_queue_length(30).

:- set_prolog_flag(stack_limit, 2_147_483_648).

% Turn off mavis
:- set_prolog_flag(optimise, true).
