-module(olifer_modifiers).
-author("prots.igor@gmail.com").

-include("olifer.hrl").

%% API
-export([
    trim/3,
    to_uc/3,
    to_lc/3,
    remove/3,
    leave_only/3,
    default/3
]).

%% API
trim(Value, [], _) when is_binary(Value) ->
    L = left_space_skip(Value, 0),
    {filter, binary:part(Value, L, right_space_skip(Value, 0) - L)};
trim(Value, [], _) ->
    {filter, Value}.

to_lc(Value, [], _) when is_binary(Value) ->
    {filter, <<<<if
                     B >= $A, B =< $Z -> B + ($a - $A);
                     true -> B
                 end>> || <<B>> <= Value>>};
to_lc(Value, [], _) ->
    {filter, Value}.

to_uc(Value, [], _) when is_binary(Value) ->
    {filter, <<<<if
                     B >= $a, B =< $z -> B - ($a - $A);
                     true -> B
                 end>> || <<B>> <= Value>>};
to_uc(Value, [], _) ->
    {filter, Value}.

remove(Value, [Pattern], AllData) ->
    remove(Value, Pattern, AllData);
remove(Value, Pattern, _) when is_binary(Value), is_binary(Pattern) ->
    remove_impl(Value, Pattern);
remove(Value, _, _) ->
    {filter, Value}.

leave_only(Value, [Pattern], AllData) ->
    leave_only(Value, Pattern, AllData);
leave_only(Value, Pattern, _)  when is_binary(Value), is_binary(Pattern)->
    leave_only_impl(Value, Pattern, <<>>);
leave_only(Value, _, _) ->
    {filter, Value}.

default(<<>>, [[]], _AllData) ->
    {filter, []};
default(<<>>, [{}], _AllData) ->
    {filter, [{}]};
default(<<>>, [Default], _AllData) ->
    {filter, Default};
default(<<>>, Default, _AllData) ->
    {filter, Default};
default(Value, _Default, _AllData) ->
    {filter, Value}.

%% INTERNAL
remove_impl(Value, <<>>) ->
    {filter, Value};
remove_impl(Value, <<First, Rest/binary>>) ->
    remove_impl(<<<<B>> || <<B>> <= Value, B =/= First>>, Rest).

leave_only_impl(<<>>, _, Acc) ->
    {filter, Acc};
leave_only_impl(<<First:1/binary, Rest/binary>>, Pattern, Acc) ->
    case binary:match(Pattern, First) of
        nomatch -> leave_only_impl(Rest, Pattern, Acc);
        _ -> leave_only_impl(Rest, Pattern, <<Acc/binary, First/binary>>)
    end.

left_space_skip(Value, I) ->
    case byte_size(Value) =/= I andalso binary:at(Value, I) of
        C when C =:= $\t; C =:= $\n; C =:= $\r; C =:= $\s -> left_space_skip(Value, I + 1);
        _ -> I
    end.

right_space_skip(Value, I) ->
    case byte_size(Value) of
        I -> I;
        S -> case binary:at(Value, S - I - 1) of
                 C when C =:= $\t; C =:= $\n; C =:= $\r; C =:= $\s -> right_space_skip(Value, I + 1);
                 _ -> S - I
             end
    end.
