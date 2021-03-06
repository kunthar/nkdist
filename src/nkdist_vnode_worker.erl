%% -------------------------------------------------------------------
%%
%% Copyright (c) 2015 Carlos Gonzalez Florido.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @private Worker module for vnode
-module(nkdist_vnode_worker).
-author('Carlos Gonzalez <carlosj.gf@gmail.com>').

-behaviour(riak_core_vnode_worker).

-export([init_worker/3, handle_work/3]).

-include("nkdist.hrl").

-record(state, {
	idx :: chash:index_as_int()
}).

%% ===================================================================
%% Public API
%% ===================================================================

%% @private
init_worker(VNodeIndex, [], _Props) ->
    {ok, #state{idx=VNodeIndex}}.


%% @private
handle_work({handoff, Data, Fun, Acc}, Sender, State) ->
	Result = do_handoff(Data, Fun, Acc),
	riak_core_vnode:reply(Sender, Result),
	{noreply, State}.



%%%===================================================================
%%% Internal
%%%===================================================================



%% @private
do_handoff([], _Fun, Acc) ->
	Acc;

do_handoff([{ProcId, CallBack, Pid}|Rest], Fun, Acc) ->
	Acc1 = Fun({proc, ProcId}, {CallBack, Pid}, Acc),
	do_handoff(Rest, Fun, Acc1).