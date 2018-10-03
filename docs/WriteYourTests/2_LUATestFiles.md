# LUA Test files

You have two differents things to take in account when you'll write your tests
using this framework: *test* and *assertions*.

*Assertions* are functions meant to test an atomic operation result.
(ie: `1+1 = 2` is an assertion)

*Test* functions represent a test (Unbelievable), they represent a set of one or
several *assertions* which are all needed to succeed to valid the test.

The framework came with several *test* and *assertion* functions to simply be
able to test verb calls and events receiving. Use the simple one as often as
possible and if you need more use the one that calls a callback. Specifying a
callback let you add assertions and enrich the test.
