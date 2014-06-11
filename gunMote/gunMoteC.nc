#include "Radio-Message.h"
#include <UserButton.h>
 
module gunMoteC @safe()
{
  uses interface Boot;
  uses interface Leds;
  
  uses interface Timer<TMilli> as Timer1;
  
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;


  uses interface Notify<button_state_t>;
  uses interface HplMsp430GeneralIO as GIO;
}

implementation  {
  message_t pkt;
  bool busy = FALSE;
  int counter = 0;
  int gameStop = 0;

  event void Boot.booted() {
    call AMControl.start();
    call Notify.enable();
  }
  
  event void Notify.notify(button_state_t val) {    // press the button
    if(val == BUTTON_PRESSED) {
      call GIO.makeOutput();
      counter++;
      if (counter <= gameStop)
      {
        call GIO.set();
        call Timer1.startOneShot(500);
        // Send this shot
        if (!busy) {
          Message* msgPtr = 
          (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          if (msgPtr == NULL) {
            return;
          }
          msgPtr->identifier = 2; // 2 = Shooting event and counter
          msgPtr->payload = counter;
          if (call AMSend.send(AM_BROADCAST_ADDR, 
              &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
            call Leds.led1On();
            call Leds.led0Off();
          }
        }
      }
    }
  }

  event void Timer1.fired(){
      call GIO.clr();
    
  }


  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Leds.led0On();
    } else {
      call AMControl.start();
    }
  }
  
  
  event void AMControl.stopDone(error_t err) {
  }


  // Receiver OTA
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
    if (len == sizeof(Message)) {
      Message* msgPtr = (Message*)payload;
      // This is the "gun" mote
      if(msgPtr->identifier == 0) { //It should stop  
        call Timer1.stop();
      } else  { 
        if (msgPtr->identifier == 1) {  //start the game with certain number of bullets
          // call Leds.led2Toggle();
          gameStop = msgPtr->payload;
          call Leds.led2Toggle();
          counter = 0;
        }
      }
    }
    return msg;
  }
  
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Off();
    }
  }

  
}