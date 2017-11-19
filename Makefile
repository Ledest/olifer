PROJECT = olifer

DEPS = jsx
TEST_DEPS = LIVR

dep_jsx       = git https://github.com/talentdeficit/jsx.git        master
dep_LIVR      = git https://github.com/koorchik/LIVR                master

TEST_DIR = test

include erlang.mk
