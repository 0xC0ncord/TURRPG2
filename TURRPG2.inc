#define __LINE__ #eval #line
#define __FILE__ #eval #file
#mode string QQQ "$$" "$$"
#mode push

#ifdef __DEBUG__
#define DEBUG_LOG(x) Log($$"(__LINE__)"$$ @ x, default.Name);
#else
#define DEBUG_LOG
#endif
