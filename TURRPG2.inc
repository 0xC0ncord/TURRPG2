#define __VERSION__ 0.01a

#define __LINE__ #eval #line
#define __FILE__ #eval #file
#mode string QQQ "$$" "$$"
#mode push

#define __VERBOSE__ 0

#ifdef __DEBUG__
#define LOGD(x) Log($$"(__LINE__)"$$ @ x, Name);
#define WARND(x) Warn($$"(__LINE__)"$$ @ x);
#define CONSOLED(x) Level.GetLocalPlayerController().ClientMessage(Name @ $$"(__LINE__):"$$ @ x);
#define PRINTD(x) LOGD(x); CONSOLED(x);

#ifeq __VERBOSE__ 1
#defeval SHOWARR(x, y) PRINTD($$"x[y]:"$$ @ x[y]);
#else
#defeval SHOWARR(x, y) LOGD($$"x[y]:"$$ @ x[y]);
#endif

#define DUMPARR(x, y) for(y = 0; y < x.Length; y++){ SHOWARR(x, y); }

#else
#define LOGD
#define WARND
#define CONSOLED
#define PRINTD
#define SHOWARR
#define DUMPARR
#endif
