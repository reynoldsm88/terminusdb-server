#!/usr/bin/env swipl

/*
 *  This file is part of TerminusDB.
 *
 *  TerminusDB is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, under version 3 of the License, or
 *  (at your option) any later version.
 *
 *  TerminusDB is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TerminusDB.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

:- [load_paths].
:- initialization(main).

%!  version_string(+Int:integer, -Str:string) is det
%
%   convert an integer form version number as supplied by
%   the =|version|= flag of =|current_prolog_flag/2|=
%   to a string representation
%
version_string(Int, Str) :-
    Major is floor( Int / 10_000 ) rem 100,
    Minor is floor( Int / 100 ) rem 100,
    Patch is Int rem 100,
    format(string(Str), '~w.~w.~w', [Major, Minor, Patch]).

:- multifile prolog:message//1.

prolog:message(error(version_error(Correct, Was), _)) -->
      {
        maplist(version_string, Correct, VersionStrings),
        atomic_list_concat(VersionStrings, " or ", AcceptedVersions),
        version_string(Was, W)
      },
      [ 'Run TerminusDB using SWI-Prolog version ~w, you are on ~w'-[AcceptedVersions, W],
        nl].

needs_version(80131).
needs_version(80130).
needs_version(80123).
needs_version(80111).
needs_version(80110).
needs_version(80003).

must_be_proper_version :-
    current_prolog_flag(version, RunningVersion),
    (    needs_version(RunningVersion)
    ->   true
    ;
        findall(Version, needs_version(Version), SupportedVersions),
        print_message(error,
                      error(version_error(SupportedVersions, RunningVersion), terminus_db_startup))
   ).

:- initialization must_be_proper_version.

initialise_hup :-
    (   current_prolog_flag(unix, true)
    ->  on_signal(hup, _, hup)
    ;   true).

:- initialise_hup.


initialise_log_settings :-
    (   getenv('TERMINUSDB_LOG_PATH', Log_Path)
    ->  set_setting(http:logfile, Log_Path)
    ;   get_time(Time),
        asserta(http_log:log_stream(user_error, Time))).

:-multifile prolog:message//1.

prolog:message(server_missing_config(BasePath)) -->
    [
    'CRITICAL ERROR: Server can\'t be started because the configuration is missing',
    nl,
    nl,
    'Run: ~s/utils/db_init first'-[BasePath],
    nl
    ].


:- reexport(core(util/syntax)).

:- use_module(server(routes)).
:- use_module(server(main)).

% Plugins
%:- use_module(plugins(registry)).

:- use_module(core(query/json_woql),[initialise_woql_contexts/0]).

:- use_module(library(http/http_log)).

:- set_test_options([run(manual)]).

hup(_Signal) :-
  thread_send_message(main, stop).

main(Argv) :-
    initialise_log_settings,
    get_time(Now),
    format_time(string(StrTime), '%A, %b %d, %H:%M:%S %Z', Now),
    http_log('terminusdb-server started at ~w (utime ~w) args ~w~n',
             [StrTime, Now, Argv]),
    initialise_woql_contexts,
    debug(terminus(main), 'initialise_woql_contexts completed', []),
    debug(terminus(main), 'initialise_log_settings completed', []),
    terminus_server(Argv),
    run(Argv).

run([test]) :-
  run_tests.
run([serve]) :-
  thread_get_message(stop).
run(_).
