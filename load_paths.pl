:- dynamic user:file_search_path/2.
:- multifile user:file_search_path/2.

add_pack_path :-
    (   getenv('TERMINUS_SERVER_PACK_DIR', PackDir)
    ->  attach_packs(PackDir)
    ;   true).

:- add_pack_path.

add_terminus_home_path :-
    prolog_load_context(file, File),
    file_directory_name(File, Dir),

    asserta(user:file_search_path(terminus_home, Dir)).

:- add_terminus_home_path.

add_core_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/core',Core),
    asserta(user:file_search_path(core, Core)).

:- add_core_path.

add_server_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/server',Server),
    asserta(user:file_search_path(server, Server)).

:- add_server_path.

add_jwt_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/prolog_jwt/prolog',Library),
    asserta(user:file_search_path(library, Library)).

:- add_jwt_path.

add_config_path :-
    % Global directory
    % asserta(user:file_search_path(config, '/etc')),
    % home or app directory
    user:file_search_path(app_preferences, App_Config),
    asserta(user:file_search_path(config, App_Config)),
    % relative path
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/config',Config),
    asserta(user:file_search_path(config, Config)).

:- add_config_path.

add_test_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/test',Config),
    asserta(user:file_search_path(test, Config)).

:- add_test_path.

add_plugin_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/plugins',Config),
    asserta(user:file_search_path(plugins, Config)).

:- add_plugin_path.

add_ontology_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/terminus-schema',Ontology),
    asserta(user:file_search_path(ontology, Ontology)).

:- add_ontology_path.

add_template_path :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/utils',Template),
    asserta(user:file_search_path(template, Template)).

:- add_template_path.
