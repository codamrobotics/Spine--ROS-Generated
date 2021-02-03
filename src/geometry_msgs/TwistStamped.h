#ifndef _ROS_geometry_msgs_TwistStamped_h
#define _ROS_geometry_msgs_TwistStamped_h

#include <stdint.h>
#ifdef __MACH__
	#include "String.h"
#else
	#include "string.h"
#endif
#include <stdlib.h>
#include "ros/msg.h"
#include "std_msgs/Header.h"
#include "geometry_msgs/Twist.h"

namespace geometry_msgs
{

  class TwistStamped : public ros::Msg
  {
    public:
      typedef std_msgs::Header _header_type;
      _header_type header;
      typedef geometry_msgs::Twist _twist_type;
      _twist_type twist;

    TwistStamped():
      header(),
      twist()
    {
    }

    virtual int serialize(unsigned char *outbuffer) const override
    {
      int offset = 0;
      offset += this->header.serialize(outbuffer + offset);
      offset += this->twist.serialize(outbuffer + offset);
      return offset;
    }

    virtual int deserialize(unsigned char *inbuffer) override
    {
      int offset = 0;
      offset += this->header.deserialize(inbuffer + offset);
      offset += this->twist.deserialize(inbuffer + offset);
     return offset;
    }

    virtual const char * getType() override { return "geometry_msgs/TwistStamped"; };
    virtual const char * getMD5() override { return "98d34b0043a2093cf9d9345ab6eef12e"; };

  };

}
#endif
