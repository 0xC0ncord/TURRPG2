#define __VERSION__ 0.01a

#define __LINE__ #eval #line
#define __FILE__ #eval #file
#mode string QQQ "$$" "$$"
#mode push

#ifdef __DEBUG__
#define LOGD(x) Log($$"(__LINE__)"$$ @ x, default.Name);
#define WARND(x) Warn($$"(__LINE__)"$$ @ x);
#else
#define LOGD
#define WARND
#endif
