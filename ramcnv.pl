#! /usr/bin/perl

open D0,">ram.data0";
open D1,">ram.data1";
open D2,">ram.data2";
open D3,">ram.data3";

$addro = 0;

while(<>){
    $bc = substr($_, 1, 2);
    $addr = substr($_, 3, 4);
    $type = substr($_, 7, 2);

    if($type eq "03"){next;}
    if($type eq "01"){next;}
    if($type ne "00"){print "Error\n"; next;}

    $addr = hex($addr)/4;
    $_ = substr($_, 9);

    for($i=$addro;$i<$addr;$i++){
        printf D0 "00\n";
        printf D1 "00\n";
        printf D2 "00\n";
        printf D3 "00\n";
        $addri = sprintf "%04x",($addro+$i);
        printf ";04$addri${type}00000000\n";
    }        

    $bci = hex($bc)/4;
    $addro = $addr + $bci;
    for($i=0; $i<$bci; $i++){
        $data0 = substr($_, 0, 2);
        $data1 = substr($_, 2, 2);
        $data2 = substr($_, 4, 2);
        $data3 = substr($_, 6, 2);

        $bc = "04";
        $addri = sprintf "%04x",$addr+$i;
        $addri =~ /(..)(..)/;
        $addr0 = $1;
        $addr1 = $2;
        $cs = -(hex($bc)+hex($addr0)+hex($addr1)+hex($type)
                +hex($data0)+hex($data1)+hex($data2)+hex($data3));

        printf ":$bc$addri$type$data0$data1$data2$data3%02x\n",($cs%256);
#        printf "$data0$data1$data2$data3\n";
        printf D0 "$data0\n";
        printf D1 "$data1\n";
        printf D2 "$data2\n";
        printf D3 "$data3\n";

        $_ = substr($_, 8);
    }
}
