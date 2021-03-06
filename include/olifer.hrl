-author("prots.igor@gmail.com").

-record(field, {name, input, rules, output, errors}).

-define(RULES_TBL, olifer_user_rules).
-define(ALIASES_TBL, olifer_user_aliases).

-define(SPEC_RULES, [<<"required">>, <<"not_empty_list">>, <<"default">>]).

%% BASIC RULES ERRORS
-define(REQUIRED, <<"REQUIRED">>).
-define(CANNOT_BE_EMPTY, <<"CANNOT_BE_EMPTY">>).

%% NUMBER RULES ERRORS
-define(NOT_NUMBER, <<"NOT_NUMBER">>).
-define(NOT_INTEGER, <<"NOT_INTEGER">>).
-define(NOT_POSITIVE_INTEGER, <<"NOT_POSITIVE_INTEGER">>).
-define(NOT_DECIMAL, <<"NOT_DECIMAL">>).
-define(NOT_POSITIVE_DECIMAL, <<"NOT_POSITIVE_DECIMAL">>).
-define(TOO_HIGH, <<"TOO_HIGH">>).
-define(TOO_LOW, <<"TOO_LOW">>).

%% STRING RULES ERRORS
-define(NOT_ALLOWED_VALUE, <<"NOT_ALLOWED_VALUE">>).
-define(TOO_LONG, <<"TOO_LONG">>).
-define(TOO_SHORT, <<"TOO_SHORT">>).
-define(WRONG_FORMAT, <<"WRONG_FORMAT">>).

%% SPECIAL RULES ERRORS
-define(WRONG_EMAIL, <<"WRONG_EMAIL">>).
-define(WRONG_URL, <<"WRONG_URL">>).
-define(WRONG_DATE, <<"WRONG_DATE">>).
-define(FIELDS_NOT_EQUAL, <<"FIELDS_NOT_EQUAL">>).

%% OTHER
-define(FORMAT_ERROR, <<"FORMAT_ERROR">>).

