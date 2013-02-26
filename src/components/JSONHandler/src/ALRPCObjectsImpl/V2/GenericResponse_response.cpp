#include "../include/JSONHandler/ALRPCObjects/V2/GenericResponse_response.h"
#include "GenericResponse_responseMarshaller.h"

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
GenericResponse_response& GenericResponse_response::operator =(const GenericResponse_response& c)
{
    success = c.success;
    resultCode = c.resultCode;
    info = c.info ? new std::string(c.info[0]) : 0;

    return *this;
}

GenericResponse_response::~GenericResponse_response(void)
{}

GenericResponse_response::GenericResponse_response(const GenericResponse_response& c)
{
    *this = c;
}

bool GenericResponse_response::checkIntegrity(void)
{
    return GenericResponse_responseMarshaller::checkIntegrity(*this);
}

GenericResponse_response::GenericResponse_response(void) : NsAppLinkRPC::ALRPCResponse(PROTOCOL_VERSION)
{}
