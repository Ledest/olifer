-module(helper).
-author("prots.igor@gmail.com").

-include("olifer.hrl").

%% API
-export([nested_object/3]).
-export([list_of/3]).
-export([list_of_objects/3]).
-export([list_of_different_objects/3]).

%% API
nested_object(<<>> = Value, _Args, _) ->
    {ok, Value};
nested_object(Value, Args, _AllData) when is_list(Value)->
    FieldsList = olifer:validate(Value, Args),
    post_processing(nested_object, FieldsList);
nested_object(_Value, _Args, _) ->
    {error, ?FORMAT_ERROR}.

list_of(<<>> = Value, _Args, _) ->
    {ok, Value};
list_of(Values, [Args], AllData) when is_list(Values) ->
    list_of(Values, Args, AllData);
list_of(Values, Args, _) when is_list(Values) ->
    {DataPropList, RulesPropList} = pred_processing(list_of, Values, Args),
    FieldsList = olifer:validate(DataPropList, RulesPropList),
    post_processing(list_of, FieldsList);
list_of(_Value, _Args, _) ->
    {error, ?FORMAT_ERROR}.

list_of_objects(<<>> = Value, _Args, _) ->
    {ok, Value};
list_of_objects(Values, [Args], AllData) when is_list(Values) ->
    list_of(Values, Args, AllData);
list_of_objects(Values, Args, _) when is_list(Values) ->
    ListOfObjects = pred_processing(list_of_objects, Values, Args, []),
    ObjFieldsList = [olifer:validate(DataPropList, RulesPropList) || {DataPropList, RulesPropList} <- ListOfObjects],
    post_processing(list_of_objects, ObjFieldsList, [], []);
list_of_objects(_Value, _Args, _) ->
    {error, ?FORMAT_ERROR}.

list_of_different_objects(<<>> = Value, _Args, _) ->
    {ok, Value};
list_of_different_objects(Values, [Args], AllData) when is_list(Values) ->
    list_of(Values, Args, AllData);
list_of_different_objects(Values, Args, _) when is_list(Values) ->
    ListOfObjects = pred_processing(list_of_different_objects, Values, Args, []),
    ObjFieldsList = [olifer:validate(DataPropList, RulesPropList) || {DataPropList, RulesPropList} <- ListOfObjects],
    Res = post_processing(list_of_objects, ObjFieldsList, [], []),
    Res;
list_of_different_objects(_Value, _Args, _) ->
    {error, ?FORMAT_ERROR}.

%% INTERNAL
pred_processing(list_of, Values, Args) ->
    pred_processing(list_of, Values, Args, [], []).

pred_processing(list_of, [], _, DataPropList, RulesPropList) ->
    {DataPropList, RulesPropList};
pred_processing(list_of, [Value|Rest], Args, DataList, RulesList) ->
    TempFieldName = erlang:make_ref(),
    pred_processing(list_of, Rest, Args, [{TempFieldName, Value}|DataList], [{TempFieldName, Args}|RulesList]).

pred_processing(list_of_objects, [], _, Acc) ->
    Acc;
pred_processing(list_of_objects, [Value|Rest], Args, Acc) ->
    pred_processing(list_of_objects, Rest, Args, [{Value, Args}|Acc]);

pred_processing(list_of_different_objects, [], _, Acc) ->
    Acc;
pred_processing(list_of_different_objects, [Object|Rest], [FieldType, TypeRules] = Args, Acc) when is_list(Object) ->
    ObjectType = proplists:get_value(FieldType, Object),
    RulesPropList = proplists:get_value(ObjectType, TypeRules),
    pred_processing(list_of_different_objects, Rest, Args, [{Object, RulesPropList}|Acc]);
pred_processing(list_of_different_objects, [Object|Rest], [_FieldType, TypeRules] = Args, Acc)  ->
    RulesPropList = proplists:get_value(undefined, TypeRules),
    pred_processing(list_of_different_objects, Rest, Args, [{Object, RulesPropList}|Acc]).

post_processing(nested_object, FieldsList) ->
    post_processing(nested_object, FieldsList, [], []);
post_processing(list_of, FieldsList) ->
    post_processing(list_of, FieldsList, [], []).

post_processing(nested_object, [], AccOK, []) ->
    Result = [{Field#field.name, Field#field.output} || Field <- AccOK],
    {ok, lists:reverse(Result)};
post_processing(nested_object, [], _AccOK, AccErr) ->
    Result = [{Field#field.name, Field#field.errors} || Field <- AccErr],
    {error, lists:reverse(Result)};
post_processing(nested_object, [#field{errors = []} = Field|RestList], AccOK, AccErr) ->
    post_processing(nested_object, RestList, [Field|AccOK], AccErr);
post_processing(nested_object, [#field{errors = _Err} = Field|RestList], AccOK, AccErr) ->
    post_processing(nested_object, RestList, AccOK, [Field|AccErr]);
post_processing(list_of, [], AccOk, AccErr) when length(AccErr) == length(AccOk) ->
    {ok, AccOk};
post_processing(list_of, [], _AccOk, AccErr) ->
    {error, AccErr};
post_processing(list_of, [#field{output = Res, errors = []}|RestList], AccOK, AccErr) ->
    post_processing(list_of, RestList, [Res|AccOK], [null|AccErr]);
post_processing(list_of, [#field{errors = Err}|RestList], AccOK, AccErr) ->
    post_processing(list_of, RestList, AccOK, [Err|AccErr]);

post_processing(list_of_objects, [], AccOk, AccErr) when length(AccErr) == length(AccOk) ->
    {ok, AccOk};
post_processing(list_of_objects, [], _AccOk, AccErr) ->
    {error, AccErr};
post_processing(list_of_objects, [Object|RestList], AccOk, AccErr) ->
    case  object_processing(Object, [], []) of
        {ok, Res} -> post_processing(list_of_objects, RestList, [Res|AccOk], [null|AccErr]);
        {error, [?FORMAT_ERROR]} -> post_processing(list_of_objects, RestList, AccOk, [?FORMAT_ERROR|AccErr]);
        {error, Res} -> post_processing(list_of_objects, RestList, AccOk, [Res|AccErr])
    end.

object_processing([], AccOk, []) ->
    {ok, lists:reverse(AccOk)};
object_processing([], _, AccErr) ->
    {error, lists:reverse(AccErr)};
object_processing([#field{name = Name, output = Output, errors = []}|Rest], AccOk, AccErr) ->
    object_processing(Rest, [{Name, Output}|AccOk], AccErr);
object_processing([#field{errors = ?FORMAT_ERROR}|Rest], AccOk, AccErr) ->
    object_processing(Rest, AccOk, [?FORMAT_ERROR|AccErr]);
object_processing([#field{name = Name, errors = Error}|Rest], AccOk, AccErr) ->
    object_processing(Rest, AccOk, [{Name, Error}|AccErr]).