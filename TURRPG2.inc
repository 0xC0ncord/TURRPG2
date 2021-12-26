#define __VERSION__ 0.01a

#define __LINE__ #eval #line
#mode string QQQ "$$" "$$"
#mode push

#define __VERBOSE__ 1

#ifdef __DEBUG__
#define LOGD(x) Log($$"(__FILE__:__LINE__)"$$ @ x);
#define WARND(x) Warn($$"(__FILE__:__LINE__)"$$ @ x);
#define CONSOLED(x) Level.GetLocalPlayerController().ClientMessage(Name @ $$"(__FILE__:__LINE__):"$$ @ x);

#ifeq __VERBOSE__ 1
#define PRINTD(x) CONSOLED(x); LOGD(x);
#else
#define PRINTD(x) LOGD(x);
#endif

// SHOWVAR prints the name of a variable and its value.
// Useful for self-documenting log statements.
#define SHOWVAR(x) PRINTD($$"x:"$$ @ x);

// SHOWARR takes an array in ARG1 and an index in ARG2
// and prints the value with the variable name. Only
// works for arrays of objects that can be converted
// directly to strings.
#define SHOWARR(x, y) PRINTD($$"x["$$ $ y $ "]:" @ x[y]);

// DUMPARR takes an array in ARG1 and an iterator in ARG2
// and prints the contents of the entire array. See SHOWARR
// for more info.
#define DUMPARR(x, y) for(y = 0; y < x.Length; y++){ SHOWARR(x, y); }

// DUMPSTATICARR takes an array in ARG1, an iterator in ARG2,
// and an array length in ARG3 and prints the contents of the
// array. See SHOWARR for more info.
#define DUMPSTATICARR(x, y, z) for(y = 0; y < z; y++){ SHOWARR(x, y); }

#else
#define LOGD
#define WARND
#define CONSOLED
#define PRINTD
#define SHOWVAR
#define SHOWARR
#define DUMPARR
#endif
