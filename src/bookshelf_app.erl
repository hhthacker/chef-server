%% @copyright 2012 Opscode, Inc. All Rights Reserved
%% @author Tim Dysinger <timd@opscode.com>
%%
%% Licensed to the Apache Software Foundation (ASF) under one or more
%% contributor license agreements.  See the NOTICE file distributed
%% with this work for additional information regarding copyright
%% ownership.  The ASF licenses this file to you under the Apache
%% License, Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain a copy of
%% the License at http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
%% implied.  See the License for the specific language governing
%% permissions and limitations under the License.

-module(bookshelf_app).

-export([start/0]).

-behaviour(application).
-export([start/2, stop/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start() ->
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),
    application:start(cowboy),
    application:start(bookshelf).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Env = bookshelf_conf:with_dispatch(
            bookshelf_conf:with_ip(
              bookshelf_conf:with_dir(
                application:get_all_env(bookshelf)))),
    cowboy:start_listener(bookshelf_http_listener, 100,
                          cowboy_tcp_transport, Env,
                          cowboy_http_protocol, Env),
    bookshelf_sup:start_link().

stop(_State) ->
    ok.
