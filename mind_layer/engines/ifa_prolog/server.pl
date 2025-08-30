% MoStar Grid - Prolog Ifá Engine Server
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- consult('odu_rules.pl').

:- http_handler('/query_odu', handle_odu_query, [method(post)]).

server(Port) :- http_server(http_dispatch, [port(Port)]).
handle_odu_query(Request) :-
    http_read_json_dict(Request, Query),
    odu_prescriptions('Ogbe-Meji', Prescriptions),
    reply_json_dict(_{odu_code: 'Ogbe-Meji', prescriptions: Prescriptions}).
