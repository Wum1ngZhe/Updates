
#import "substrate.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>


size_t (* original_ssl_read)(void *,void *,size_t,size_t *);
size_t hook_ssl_read(void *s,void *buf,size_t buf_size,size_t *err);

size_t (* original_ssl_write)(void *,void *,size_t,size_t *);
size_t hook_ssl_write(void *s,void *buf,size_t buf_size,size_t *err);


CFPropertyListRef (*CFPropertyListCreateWithData_orig)(CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error) = NULL;
CFPropertyListRef CFPropertyListCreateWithData_hooked(CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error);

CFDataRef (*CFPropertyListCreateData_orig)(CFAllocatorRef allocator, CFPropertyListRef propertyList, CFPropertyListFormat format, CFOptionFlags options, CFErrorRef *error);
CFDataRef CFPropertyListCreateData_hooked(CFAllocatorRef allocator, CFPropertyListRef propertyList, CFPropertyListFormat format, CFOptionFlags options, CFErrorRef *error);


size_t hook_ssl_read(void *s,void *buf,size_t buf_size,size_t *err)
{
    size_t ret=0;
    ret=original_ssl_read(s,buf,buf_size,err);
    NSLog(@"ssl receive message len=%lu\n%s",buf_size,buf);
    return ret;
}

size_t hook_ssl_write(void *s,void *buf,size_t buf_size,size_t *err)
{
    NSLog(@"ssl send message len=%lu\n%s",buf_size,buf);
    return original_ssl_write(s,buf,buf_size,err);
}

//CFPropertyListRef _CFPropertyListCreateWithData(CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error);;

CFPropertyListRef CFPropertyListCreateWithData_hooked(CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error) {
    CFPropertyListRef list = CFPropertyListCreateWithData_orig(allocator, data, options, format, error);
    NSDictionary *dict((NSDictionary *) list);
    
    NSLog(@"CFPropertyListCreateWithData %@", dict);
    
    return list;
}

CFDataRef CFPropertyListCreateData_hooked(CFAllocatorRef allocator, CFPropertyListRef propertyList, CFPropertyListFormat format, CFOptionFlags options, CFErrorRef *error) {
    
    NSDictionary *dict((NSDictionary *) propertyList);
    
    NSLog(@"CFPropertyListCreateData %@", dict);
    
    CFDataRef data = CFPropertyListCreateData_orig(allocator, propertyList, format, options, error);

    return data;
}


CFHTTPMessageRef (* orig_CFHTTPMessageCreateRequest)(CFAllocatorRef alloc, CFStringRef requestMethod, CFURLRef url, CFStringRef httpVersion) ;

CFHTTPMessageRef hooked_CFHTTPMessageCreateRequest(CFAllocatorRef alloc, CFStringRef requestMethod, CFURLRef url, CFStringRef httpVersion) {
    CFHTTPMessageRef msgRef = orig_CFHTTPMessageCreateRequest(alloc, requestMethod, url, httpVersion);
    
    NSLog(@"Create HTTP request method %@ for URL %@", (__bridge NSString *)requestMethod, (__bridge NSURL *)url );
    
    return msgRef;
}


extern CFTypeRef
CFURLRequestCreateHTTPRequest(
                              CFAllocatorRef            alloc,
                              CFHTTPMessageRef          httpRequest,
                              CFArrayRef            bodyParts,
                              int   cachePolicy,
                              CFTimeInterval            timeout,
                              CFURLRef                  mainDocumentURL);

CFTypeRef (*orig_CFURLRequestCreateHTTPRequest)(CFAllocatorRef alloc, CFTypeRef httpRequest, CFArrayRef    bodyParts, int cachePolicy, CFTimeInterval timeout, CFURLRef mainDocumentURL);

CFTypeRef
hooked_CFURLRequestCreateHTTPRequest(
                                     CFAllocatorRef            alloc,
                                     CFHTTPMessageRef          httpRequest,
                                     CFArrayRef            bodyParts,
                                     int   cachePolicy,
                                     CFTimeInterval            timeout,
                                     CFURLRef                  mainDocumentURL)
{
    CFTypeRef retRef = orig_CFURLRequestCreateHTTPRequest(alloc, httpRequest, bodyParts, cachePolicy, timeout, mainDocumentURL);
    
    NSLog(@"Create URL HTTP request for URL %@ body parts %@", (__bridge NSURL *)mainDocumentURL, (__bridge NSArray *)bodyParts  );
    
    return retRef;
}
// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: initialize                                          |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
__attribute__((constructor))
static void initialize()
{
//    void *lockdown_ssl_read=NULL;
//    void *lockdown_ssl_write=NULL;
//    void *CFPropertyListCreateWithDataP=NULL;
//    void *CFPropertyListCreateDataP=NULL;
//    if(0==freopen("/var/log/lockdownd_message","a+",stderr))
//    {
//        NSLog(@"redirect stderr fail %d",errno);
//    }
//    lockdown_ssl_read=MSFindSymbol(NULL,"_SSLRead");
//    lockdown_ssl_write=MSFindSymbol(NULL,"_SSLWrite");
//    CFPropertyListCreateWithDataP = MSFindSymbol(NULL,"_CFPropertyListCreateWithData");
//    CFPropertyListCreateDataP = MSFindSymbol(NULL,"_CFPropertyListCreateData");
//    MSHookFunction(lockdown_ssl_read,(void *)hook_ssl_read,(void **)&original_ssl_read);
//    MSHookFunction(lockdown_ssl_write,(void *)hook_ssl_write,(void **)&original_ssl_write);
//    if (CFPropertyListCreateWithDataP == NULL)
//    {
//        NSLog(@"CFPropertyListCreateWithData not found!");
//    } else
//    {
//         MSHookFunction(CFPropertyListCreateWithDataP, (void *)CFPropertyListCreateWithData_hooked , (void **)&CFPropertyListCreateWithData_orig);
//    }
//
//    if (CFPropertyListCreateDataP == NULL)
//    {
//        NSLog(@"CFPropertyListCreateDataP not found!");
//    } else
//    {
//        MSHookFunction(CFPropertyListCreateDataP, (void *)CFPropertyListCreateData_hooked , (void **)&CFPropertyListCreateData_orig);
//    }
    void *CFHTTPMessageCreateRequest=NULL;
    CFHTTPMessageCreateRequest=MSFindSymbol(NULL,"_CFHTTPMessageCreateRequest");
    if (CFHTTPMessageCreateRequest != NULL)
    {
        NSLog(@"Hooking CFHTTPMessageCreateRequest");
         MSHookFunction(CFHTTPMessageCreateRequest,(void *)hooked_CFHTTPMessageCreateRequest,(void **)&orig_CFHTTPMessageCreateRequest);
    }
    
    void *CFURLRequestCreateHTTPRequest=NULL;
    CFURLRequestCreateHTTPRequest=MSFindSymbol(NULL,"_CFURLRequestCreateHTTPRequest");
    if (CFURLRequestCreateHTTPRequest != NULL)
    {
        NSLog(@"Hooking CFURLRequestCreateHTTPRequest");
        MSHookFunction(CFURLRequestCreateHTTPRequest,(void *)hooked_CFURLRequestCreateHTTPRequest,(void **)&orig_CFURLRequestCreateHTTPRequest);
    }
}
