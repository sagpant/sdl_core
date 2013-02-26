#include "../include/JSONHandler/ALRPCObjects/V2/Show_response.h"
#include "Show_responseMarshaller.h"

namespace
{
    const int PROTOCOL_VERSION = 2;
}

/*
  interface Ford Sync RAPI
  version   2.0O
  date      2012-11-02
  generated at  Thu Jan 24 06:36:23 2013
  source stamp  Thu Jan 24 06:35:41 2013
  author    robok0der
*/

using namespace NsAppLinkRPCV2;
Show_response& Show_response::operator =(const Show_response& c)
{
    success = c.success;
    resultCode = c.resultCode;
    info = c.info ? new std::string(c.info[0]) : 0;

    return *this;
}

Show_response::~Show_response(void)
{}

Show_response::Show_response(const Show_response& c)
{
    *this = c;
}

bool Show_response::checkIntegrity(void)
{
    return Show_responseMarshaller::checkIntegrity(*this);
}

Show_response::Show_response(void) : NsAppLinkRPC::ALRPCResponse(PROTOCOL_VERSION)
{}
