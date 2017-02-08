#include "unistd.h"
#include "getopt.h"
#include "Vvscale_verilator_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define VCD_PATH_LENGTH 256

int main(int argc, char **argv, char **env) {
  
  int c;
  int digit_optind = 0;
  char vcdfile[VCD_PATH_LENGTH];

  strncpy(vcdfile,"tmp.vcd",VCD_PATH_LENGTH);


  while (1) {
    int this_option_optind = optind ? optind : 1;
    int option_index = 0;
    static struct option long_options[] = {
      {"vcdfile", required_argument, 0,  0 },
      {0,         0,                 0,  0 }
    };

    c = getopt_long(argc, argv, "",
                    long_options, &option_index);
    if (c == -1)
      break;
    
    switch (c) {
    case 0:
      if (optarg)
        strncpy(vcdfile,optarg,VCD_PATH_LENGTH);
      break;
    default:
      break;
    }
  }

  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  Vvscale_verilator_top* verilator_top = new Vvscale_verilator_top;
  verilator_top->trace(tfp, 99); // requires explicit max levels param
  tfp->open(vcdfile);

  FILE *fd;
  int  i;
  char str[256];
  char data[64];
  int  bytec, addr, rtype, op;

  fd = fopen("./loadmem.ihex","r");
  if( fd == NULL ){
    printf("ERROR!! loadmem.ihex not found\n");
    return -1;
  }

  while(fgets(str, sizeof(str), fd)){
    sscanf(str, ":%2x%4x%2x%s", &bytec, &addr, &rtype, data);
    if(rtype==0 &&
        (bytec == 16 || bytec == 12 || bytec == 8 || bytec == 4)){
      for(i=0; i<bytec/4; i = i+1){
        sscanf(data, "%8x%s", &op, data);
        verilator_top->v__DOT__DUT__DOT__chip__DOT__imem__DOT__ram3__DOT__ram[addr/4+i] = (op    )&0x0ff;
        verilator_top->v__DOT__DUT__DOT__chip__DOT__imem__DOT__ram2__DOT__ram[addr/4+i] = (op>>8 )&0x0ff;
        verilator_top->v__DOT__DUT__DOT__chip__DOT__imem__DOT__ram1__DOT__ram[addr/4+i] = (op>>16)&0x0ff;
        verilator_top->v__DOT__DUT__DOT__chip__DOT__imem__DOT__ram0__DOT__ram[addr/4+i] = (op>>24)&0x0ff;
      }
    }else if ((rtype==3)|(rtype==4)|(rtype==5)){
    }else if (rtype==1){
      printf("Running ...\n");
    }else{
      printf("ERROR!! Not support ihex format\n");
      printf("%s\n",str);
      return -1;
    }
  }

  vluint64_t main_time = 0;
  int keyin, xmodem, block, check, num;
  xmodem = -6;
  char buf[128];
  FILE *fp;
  system("stty -echo -icanon min 1 time 0");
  while (!Verilated::gotFinish()) {
    verilator_top->reset = (main_time < 1000) ? 1 : 0;
    if (main_time % 100 == 0){
      verilator_top->clk = 0;
      if((xmodem == -5)|(xmodem == -6)){ //NOP
        if((verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__sel)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__wr)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart__DOT__address==2)){
          putc((char)verilator_top->v__DOT__DUT__DOT__chip__DOT__ss_hwdata, stdout);
        }
        if((verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__sel)&
           (~verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__wr)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__cnt==0)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart__DOT__address==1)){
          keyin = getc(stdin);
          if(keyin=='q'){printf("q\n");break;}
          else if(keyin=='d'){xmodem = -5;}
          else if((keyin=='\n')&(xmodem==-5)){xmodem = -4;}
          else{xmodem = -6;}
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = keyin;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__cnt = 3;
        }
      }else if(xmodem == -4){ // wait NAK
        if((verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__sel)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__wr)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart__DOT__address==2)){
          if(verilator_top->v__DOT__DUT__DOT__chip__DOT__ss_hwdata==0x15){
            xmodem = -3;
            block = 1;
            fp = fopen("xmodem.dat", "rb");
          }else{
            putc((char)verilator_top->v__DOT__DUT__DOT__chip__DOT__ss_hwdata, stdout);
          }
        }
      }else if(xmodem == -3){ // send SOH
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = 0x01;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          xmodem = -2;
        }
      }else if(xmodem == -2){ // send block
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = block;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          xmodem = -1;
        }
      }else if(xmodem == -1){ // send block bar
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = ~block;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          xmodem = 0;
          num = fread(&buf, 1 ,128 ,fp);
          check = 0;
        }
      }else if((xmodem >=0) && (xmodem<128)){ // send data
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          if(xmodem<num){
            verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = buf[xmodem];
            check += buf[xmodem];
          }else{
            verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = 0x1a;
            check += 0x1a;
          }
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          xmodem++;
        }
      }else if(xmodem == 128){ // send check sum
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = check;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          xmodem = 129;
        }
      }else if(xmodem == 129){ // wait ACK
        if((verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__sel)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__wr)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart__DOT__address==2)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__ss_hwdata==0x06)){
          if(num == 128){
            xmodem = -3;
            block++;
          }else{
            xmodem = 130;
          }
        }
      }else if(xmodem == 130){ // send EOT
        if(verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o==1){
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__dout_o = 0x04;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__empty_o = 0;
          verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__cnt = 3;
          xmodem = 131;
        }
      }else if(xmodem == 131){ // wait ACK
        if((verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__sel)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart_sim__DOT__wr)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__uart__DOT__address==2)&
           (verilator_top->v__DOT__DUT__DOT__chip__DOT__ss_hwdata==0x06)){
          xmodem = -6;
        }
      }
    }
    if (main_time % 100 == 50)
      verilator_top->clk = 1;
    verilator_top->eval();
    tfp->dump(main_time);
    main_time += 50;
  }
  delete verilator_top;
  tfp->close();
  system("stty echo -icanon min 1 time 0");
  exit(0);
}
