#include "targetMote.h"

configuration targetMoteAppC  {}
implementation {

  components targetMoteC as App;
  
  components MainC, LedsC;
  components new TimerMilliC() as Timer;
  components new HamamatsuS1087ParC() as LightSensor;
  components SerialStartC;
    
  // for debugging: use Serial interface, later change to radio
  //components ActiveMessageC as ActiveMessage;
  //components new AMSenderC(AM_LASERRADIO) as Sender;
  //components new AMReceiverC(AM_LASERRADIO) as Receiver;
  
  components SerialActiveMessageC as ActiveMessage;
  components new SerialAMSenderC(AM_LASERRADIO) as Sender;
  components new SerialAMReceiverC(AM_LASERRADIO) as Receiver;
  
  ///////////////////////////////////////////////////////////// 
  // wiring
  ///////////////////////////////////////////////////////////// 
  
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer -> Timer;
  
  App.Read -> LightSensor;
  
  App.ActiveMessage -> ActiveMessage;
  App.Send -> Sender;
  App.Receive -> Receiver;
}

