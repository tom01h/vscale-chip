#include "defines.h"
#include "serial.h"

#define SERIAL_SCI_NUM 1

#define SH2_J202_SCI0 ((volatile struct sh2_j202_sci *)0x00008000)

struct sh2_j202_sci {
  volatile uint32 BR;  // Baud Rate
//      [15:8] div1
//      [7:0]  div0
//      9600bps @ 50MHz
//      50MHz/9600/4 = 1302 = 20*65 = (div0+2) * div1
//      div1=65, div0=18
  volatile uint32 St;  // Status
//      [1] TXF (TX Full)
//      [0] RXE (RX Empty)
  volatile uint32 Data; // Data
};

uint32 rxdata;

#define SH2_J202_SCI_ST_RXE   (1<<0)
#define SH2_J202_SCI_ST_TXF   (1<<1)

static struct {
  volatile struct sh2_j202_sci *sci;
} regs[SERIAL_SCI_NUM] = {
  { SH2_J202_SCI0 },
};

/* デバイス初期化 */
int serial_init(int index)
{
  unsigned char dummy;
  volatile struct sh2_j202_sci *sci = regs[index].sci;

  sci->BR = 18+65*0x100;
  //  sci->BR = 2+2*0x100;
  while(serial_is_recv_enable(index)) dummy = sci->Data;
  return 0;
}

/* 送信可能か？ */
int serial_is_send_enable(int index)
{
  volatile struct sh2_j202_sci *sci = regs[index].sci;
  return (!(sci->St & SH2_J202_SCI_ST_TXF));
}

/* １文字送信 */
int serial_send_byte(int index, unsigned char c)
{
  volatile struct sh2_j202_sci *sci = regs[index].sci;

  
  /* 送信可能になるまで待つ */
  while (!serial_is_send_enable(index))
    ;
  sci->Data = c;

  return 0;
}

/* 受信可能か？ */
int serial_is_recv_enable(int index)
{
  volatile struct sh2_j202_sci *sci = regs[index].sci;
  return (!(sci->St & SH2_J202_SCI_ST_RXE));
}

/* １文字受信 */
unsigned char serial_recv_byte(int index)
{
  volatile struct sh2_j202_sci *sci = regs[index].sci;
  unsigned char c;

  /* 受信文字が来るまで待つ */
  while (!serial_is_recv_enable(index))
    ;
  c = sci->Data;

  return c;
}
