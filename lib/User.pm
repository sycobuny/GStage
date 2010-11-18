package User;

use warnings;
use strict;
use Method::Signatures;
use Hash::Util::FieldHash qw(id);

# class variables
Hash::Util::FieldHash::idhashes \ our (
    %server,    # the server we're connected to
    %socket,    # raw connection to the server
    %fragment,  # unfinished line fragment from the socket
    %nickname,  # IRC nickname
    %username,  # IRC username
    %mask,      # the masked host (saving cycles)
    %channels,  # the channels this user has joined
);

my (@masks);

########
# public
########

method new($class: $server, $socket) {
    my ($self) = bless(\my ($o), ref($class)||$class);
    my ($mask, @octets);

    $mask = '';
    @octets = reverse split(/\./, $socket->peerhost);

    foreach my $index (0..3) { $mask .= $masks[$index][ $octets[$index] ] }
    $mask .= 'this.chat.server';

    $server{id $self}   = $server;
    $socket{id $self}   = $socket;
    $mask{id $self}     = $mask;
    $channels{id $self} = {};

    Hash::Util::FieldHash::register($self);
    Hash::Util::FieldHash::register($self, \(
        %server, %socket, %fragment, %nickname, %username, %mask, %channels
    ));

    return $self;
}

method find_user($class: $socket) {
    foreach my $id (keys %socket) {
        return Hash::Util::FieldHash::id_2obj($id)
            if ($socket == $socket{$id});
    }
}

method read_data {
    my ($fragment, $socket, $input);
    $fragment = $fragment{id $self};
    $socket   = $socket{id $self};

    if ($socket->sysread($input, 1024)) {
        my ($line);
        local ($1, $2);

        while ($input =~ /^([^\n]*)\n([^\n]*)/) {
            if ($fragment) {
                $line = "$fragment$1";
                $fragment = ''
            } else {
                $line = $1;
            }

            $self->parse($line);
            $input = $2;
        }

        $fragment = $input;
    } else { print "sad\n" }
}

method parse($line) {
    print "the line I just got was $line!\n";
}

method add_to_channel($channel) {
    my ($channels) = $channels{id $self};
    return if $channels{$channel->name};

    $channels{$channel->name} = $channel;
    $channel->add_user($self);
}

method remove_from_channel($channel) {
    my ($channels) = $channels{id $self};
    return unless $channels{$channel->name};

    delete $channels{$channel->name};
    $channel->delete_user($self);
}

method hostmask {
    sprintf("%s!%s@%s", $nickname{id $self}, $username{id $self},
            $mask{id $self});
}

method server { $server{id $self} }
method channels { values %{ $channels{id $self} } }

@masks = (
    [qw(wjoi rarv iocg ygmh zsqi vvgj axoo rrqw evud bvdf smom gjaw yjgx
        uyqi lqjw wtob hrnv llfh elyy 1uk1 yqgd fmvm tzsc nnxa brgd guyg
        vxxn hvdz kjhy ckhk ywvx nyvx npha qwyp eezt sbjc avng zgxr eroj
        xiph axou 1uk0 pcjp 1uk2 olyy svna xnph tdge okkh hgic razg qgal
        rjho tiom mcft pkvd zulp rozk pist kyak mofz nouo nmww xblv odwg
        vwmg xvab fmzy hsxa brwx nrxt cvst 1uk3 ksqq uyfc puei 1uk4 gvpx
        xrxn sthd chop frjy juzl 1uk5 erbe ebpp iphr 1uk6 miqw qeug vvqb
        vqar rase 1uk7 cufy emkp cwhq mfas wuwa cmme vxyl wyjh pgxv 1uk8
        qvfm fnua mfed tiee ecls 1uk9 cpak yvwu saxs jexx brwx imwp lfdg
        dtzx 1ukc bjzy qedi lbon pxjg vnms upei 1uka 1ukb zgrt mplb rsms
        ebqz vurk wkpd euny tpzj tczv mxhx fcft bjgn kjqd locp rawa iaka
        tkaf xdvr kuho haad zbjw pouo cwkq pttb qnuc knxl dcqz rhyi vdmu
        gtzq jiqz linj prsf qyte jmay pkcg audc gqro 1ukd 1uke occp jcbl
        xlcu pgvd jgyi oeoc qarn ydke xhzk fhtj kytt obfb usae qivl wner
        xvfa mwxs exbs rrpb cmrq yepm cbxd wapy phmv 1ukf zxsz 1ilf oxsh
        uwkt kemf lcpj pzbg rmzt raiw icgp kstn ufvp hezi cvur eols wbps
        jzdt ztlb qxrd jdfz fwqh futu tmca awho tmdq cznw zedt ddph lsft
        vptu 1ukg cjeo xdjs uvbq ctdz xtmb stuc gcwi xelv tblq drvi vfbc
        ojya asdh hfdl smmb exel 1il3 lekc pyuj tbdz lnwo xxyk 1ukg xqaq
        wifm xuke xdhf zian nqlw cyts uulk hvmy iofp)],

    [qw(vevl jkzg araj bjzy ivxb tuxc cgge sbul stti pzlk ubju qimx lhug
        nsaj qbem dpig 2uk0 pqkf wmor 2uk1 meva eizq uyra ybpl kowi iohm
        dole gvfb bhoc gkwd skhb ogit 2uk2 ntxd 2uk3 zcxt dckg drsd jmpc
        oivf axou eoxd wnjv vbmz 2uk4 svna fqju wlul 2uk5 djah ssek ivle
        2uk6 2uk7 rwme wkoo aubc ikgo ujra gwgu 2uk8 juvj fwgw hexv jwyh
        olos nfcl aplx yeiq 2uk9 wlnn bbmb otqs 2il0 wwpv 2il1 2il2 2il3
        2il4 2il5 zypf xdsr czxj bjoc 2il6 pdrp yudm 2il7 lyfb gtry hkjg
        zamr oaaj 2il8 ugiw rltv qbjf etkp zdqz dxks gqbc jkjs pevd caxr
        jhsl gizc muvb lsbi 2il9 2uka nnpb 2ukb pdoi 2ukc otan axbb 2ukd
        xczv 2uke pnvj zrmw 2ukf qgvh udim ctlu 2ukg 2ila ardh gopl 2ilb
        ctcd 2ilc sjmg jmsl parp tczv kbhm muof rbsw 2ild nmww odwf pnkm
        yifw epmc gfpz xxld junv 2ile cwkq 2ilf qjrc uoxt jokx fwgw xagd
        afmu ofao tbcy cikr ouwj vvog sfzv 2ilg qgsk cmik xxtg vdhs zlsd
        qtoj i2la i2lb qkjx zcmc ktgh lxqs i2lc ncle calu wypq i2ld fuzq
        i2le dick wklv oves i2lf wybe yzgc bcue xdjs i2lg baru wuox ancn
        cyxx yxae hmuq vrlr ebpp esof rzgv pvhn aleu upuv ykmu lkxt vfjn
        lxyq oxpj iyky ifxs cdrw u2ka xpkn zovk ktzf u2ka u2kb lfpz epcw
        bnju goss lqjk ixqj u2kc guoq u2kd yskb u2ke u2kf mros jjmn bufb
        ojya asdh u2kg i2ka i2kb rfxv krze wlti i2kc cihv nptx i2kd mgou
        i2ke ovci i2kf nztn lvfj i2kg jneb jjef bawf)],
 
    [qw(wjoi jkzg zagk aifc jydv vvgj rnjo kjkz plmm pzlk 3aaa gjaw admw
        odmg tbir dpig ntau gxht wmor oiwn bwgc 3abc 3abd enfv unzb weij
        ezfj hvdz 3a3b 3acd 3bsf clfm grmj cvfd 3fgc af3c ab33 zgxr a3aa
        b3bb hmni hcak wnjv nlwf 3z3q 3a3q a3zq wlul okkh xeqd obyk jj3q
        3wer qogb lrcw rqdk aubc 3t35 36yu 3hfd xngm jfym uoap hegx odwg
        aiyw jcbl bwcj f3gh hh3g nrxt cvst 3af5 ttda 3yhd zpyz pcbg mlxn
        pto3 sthd p3yi ewcl hnwg j3j3 ldk3 3mfn yudm fsui gcik hzif hkjg
        3nfn fcch d3df z3g3 zvex tojz a3fg lok3 knot tyvx hlfp srje ssjq
        def3 gizc mfed lsbi a3t3 g3gh cpak mlon saxs a3yt rddf uipv wqfj
        3w3r 3rw3 qpwt ewr3 lrtd hjdg gdsy upei t33t nslo vdbv yken a3yd
        yhoe a3r3 wkpd ktgv wr3e pvhe ysyk t3tt iuw3 sptp locp njoa xzzc
        mctq ouja qw3r yxro mfku onyi pqjv pttb sfby qw3e cvqa icsq qwdp
        gtzq msts t3ty cikr mzvw yxae gtsn ldrl lryk t3td vbfe occp eegy
        a3rw q3te oduy getg 73rw q3ty xhzk p3ty kytt calu li3k uysz cpjs
        xvfa giyd wapy sznd lik3 yepm cadc wr3t itvw q3tw zxsz grnd iesh
        ftiw kenf bjin wp30 jhnc ingn chpb pu3y put3 weij lqyj fdde efmk
        fcew zvhu zwld q3tz zz3z irnu a3zz awho yzfq wr3d a3zq 3tzz xfjv
        aoxj t3zg 3gun xtfv 3tub toy3 3rot sjis ro3y xsme y33y 3qze vfbc
        ki3t k3it ngun 3kti t3ik ti3k lekc pyuj ipjx tik3 6yk3 io3k oraq
        q3ts w3tw wet3 nztn wap3 3pow qdcj uksq bawf)],

    [qw(difa 4aaa iocg icgp zsqi 44ab 4aac rrqw plmm yray ubju wjoa ezbl
        uyqi qbem wtob llfh 4dad elyy uhvl bwgc cgns uyra ybpl npzr 4aae
        4aef gvfb bhoc 44ag nhzc nyxv 4aah 44ai 44aj zcxt nfyy hmzq tynf
        44kk 4aal fdkx 4aam fter 4dan 4eao fqju 4aep bqbc 4qaq obyk ivle
        44ar tiom mcft 4was 4wat rozk btqn gwgu ekxy xsfa yafw hexv ckwn
        gnza xvab bwcj hsxa jgbg yaip sqnv yrmc whxs vzfw jjsv aqpk xkxh
        ntxd pyle yyzh zvnf juzl xgxm tvmx pdrp qvzj zwkg miqw qeug vvqb
        zamr rase uwkt cufy emkp qbjf xbjb nrbs cmme vxyl hlfp pevd yllz
        jhsl fnua 4uau dawt ecls 4aav 44aw jwoj ndrl 4xrx otan imwp kecr
        xczv hfyl ugba tszv lbon pxjg 44yy ctlu ggqa auwu ardh pzxv xsqz
        ctcd vurk sjmg jmsl tpzj cqfx kbhm odfq prdq iphr nmww rawa iaka
        mctq hypn ouja haad iiat unzb ansy mkzk yljq knxl jokx icsq vdmu
        afmu ezfr tbcy prsf ouwj 4z4z sfzv crlh lryk vrsm nhrs aa44 npre
        ab44 aac4 tzqu qkjx add4 zjhm ade4 aef4 vzci nsvu a4g4 asks fuzq
        hlcu dick arh4 aei4 cmrq nwon yzgc erj4 aek4 rgvo ale4 atin iesh
        aem4 pmtx bjin wlws fpbz ingn ann4 kzoa ezpj alht lqyj aao4 ap44
        spvk neeo aq44 rr44 bcya 4s44 tmca fsvo yzfq usca as4s olyy t4tp
        aq44 r44s cjeo rjtd uvbq ctdz inez sjis hzuf xelv tblq jjmn kdgk
        fqmu kmvq hfdl hfvk zbvy tkgh krze xswl tvrc cihv jkyd sst4 xqaq
        ymih xuke ssu4 avv4 ww44 ktzf qdcj hvmy x4x4)],
);

1;
