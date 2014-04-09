
typedef long size_t;

#if 0
size_t iconv(void*, const char**, size_t*, char**, size_t*)
{
    return 0;
}
#else
size_t iconv(void*, const char**, size_t*, char**, size_t*)
{
    return 0;
}
#endif


char out[30];
size_t i, j;


#if 0   // method 1

template <typename T>
size_t iconv(void* cd, const T inbuf, size_t *inbytesleft, char **outbuf, size_t *outbytesleft)
{
    return iconv(cd,  const_cast<T>(inbuf), inbytesleft, outbuf, outbytesleft);
}

void test_iconv(const char* s)
{
    iconv(0, &s, &i, (char**)&out, &j);
}

#else  // method 2

template<class T>
class sloppy {}; 

// convert between T** and const T** 
template<class T>
class sloppy<T**>
{
    T** t;
    public: 
    sloppy(T** mt) : t(mt) {}
    sloppy(const T** mt) : t(const_cast<T**>(mt)) {}

    operator T** () const { return t; }
    operator const T** () const { return const_cast<const T**>(t); }
};

void test_iconv(const char* s)
{
    iconv(0, sloppy<char**>(&s), &i, (char**)&out, &j);
}

#endif

// http://stackoverflow.com/questions/11421439/how-can-i-portably-call-a-c-function-that-takes-a-char-on-some-platforms-and
