#ifndef _ROS_actionlib_TestRequestFeedback_h
#define _ROS_actionlib_TestRequestFeedback_h

#include <stdint.h>
#ifdef __MACH__
	#include "String.h"
#else
	#include "string.h"
#endif
#include <stdlib.h>
#include "ros/msg.h"

namespace actionlib
{

  class TestRequestFeedback : public ros::Msg
  {
    public:

    TestRequestFeedback()
    {
    }

    virtual int serialize(unsigned char *outbuffer) const override
    {
      int offset = 0;
      return offset;
    }

    virtual int deserialize(unsigned char *inbuffer) override
    {
      int offset = 0;
     return offset;
    }

    virtual const char * getType() override { return "actionlib/TestRequestFeedback"; };
    virtual const char * getMD5() override { return "d41d8cd98f00b204e9800998ecf8427e"; };

  };

}
#endif
