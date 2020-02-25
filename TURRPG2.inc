#define __VERSION__ 0.01a

#define __LINE__ #eval #line
#define __FILE__ #eval #file
#mode string QQQ "$$" "$$"
#mode push

#ifdef __DEBUG__
#define LOGD(x) Log($$"(__LINE__)"$$ @ x, Name);
#define WARND(x) Warn($$"(__LINE__)"$$ @ x);
#define CLIENTMESSAGED(x, y) x.ClientMessage(Name @ $$"(__LINE__):"$$ @ y);
#else
#define LOGD
#define WARND
#define CLIENTMESSAGED
#endif
