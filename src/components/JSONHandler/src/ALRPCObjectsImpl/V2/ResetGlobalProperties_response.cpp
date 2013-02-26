#include "../include/JSONHandler/ALRPCObjects/V2/ResetGlobalProperties_response.h"
#include "ResetGlobalProperties_responseMarshaller.h"

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
ResetGlobalProperties_response& ResetGlobalProperties_response::operator =(const ResetGlobalProperties_response& c)
{
    success = c.success;
    resultCode = c.resultCode;
    info = c.info ? new std::string(c.info[0]) : 0;

    return *this;
}

ResetGlobalProperties_response::~ResetGlobalProperties_response(void)
{}

ResetGlobalProperties_response::ResetGlobalProperties_response(const ResetGlobalProperties_response& c)
{
    *this = c;
}

bool ResetGlobalProperties_response::checkIntegrity(void)
{
    return ResetGlobalProperties_responseMarshaller::checkIntegrity(*this);
}

ResetGlobalProperties_response::ResetGlobalProperties_response(void) : NsAppLinkRPC::ALRPCResponse(PROTOCOL_VERSION)
{}
