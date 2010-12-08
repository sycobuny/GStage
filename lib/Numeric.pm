#
# GStage: a ridiculously (and intentionally) buggy IRC server
# lib/Numeric.pm: easy packaging of RFC 1459 numerics
#
# Copyright (c) 2010 Stephen Belcher (sycobuny)
#

package Numeric;

use warnings;
use strict;

# WELCOME
sub RPL_WELCOME           () { 001 }
sub RPL_YOURHOST          () { 002 }
sub RPL_CREATED           () { 003 }
sub RPL_MYINFO            () { 004 }
sub RPL_BOUNCE            () { 005 }

# ERRORS
sub ERR_NOSUCHNICK        () { 401 }
sub ERR_NOSUCHSERVER      () { 402 }
sub ERR_NOSUCHCHANNEL     () { 403 }
sub ERR_CANNOTSENDTOCHAN  () { 404 }
sub ERR_TOOMANYCHANNELS   () { 405 }
sub ERR_WASNOSUCHNICK     () { 406 }
sub ERR_TOOMANYTARGETS    () { 407 }
sub ERR_NOORIGIN          () { 409 }
sub ERR_NORECIPIENT       () { 411 }
sub ERR_NOTEXTTOSEND      () { 412 }
sub ERR_NOTOPLEVEL        () { 413 }
sub ERR_WILDTOPLEVEL      () { 414 }
sub ERR_UNKNOWNCOMMAND    () { 421 }
sub ERR_NOMOTD            () { 422 }
sub ERR_NOADMININFO       () { 423 }
sub ERR_FILEERROR         () { 424 }
sub ERR_NONICKNAMEGIVEN   () { 431 }
sub ERR_ERRONEOUSNICKNAME () { 432 }
sub ERR_NICKNAMEINUSE     () { 433 }
sub ERR_NICKCOLLISION     () { 436 }
sub ERR_USERNOTINCHANNEL  () { 441 }
sub ERR_NOTONCHANNEL      () { 442 }
sub ERR_USERONCHANNEL     () { 443 }
sub ERR_NOLOGIN           () { 444 }
sub ERR_SUMMONDISABLED    () { 445 }
sub ERR_USERSDISABLED     () { 446 }
sub ERR_NOTREGISTERED     () { 451 }
sub ERR_NEEDMOREPARAMS    () { 461 }
sub ERR_ALREADYREGISTERED () { 462 }
sub ERR_NOPERMFORHOST     () { 463 }
sub ERR_PASSWDMISTMATCH   () { 464 }
sub ERR_YOUREBANNEDCREEP  () { 465 }
sub ERR_KEYSET            () { 467 }
sub ERR_CHANNELISFULL     () { 471 }
sub ERR_UNKNOWNMODE       () { 472 }
sub ERR_INVITEONLYCHAN    () { 473 }
sub ERR_BANNEDFROMCHAN    () { 474 }
sub ERR_BADCHANNELKEY     () { 475 }
sub ERR_NOPRIVILEGES      () { 481 }
sub ERR_CHANOPRIVSNEEDED  () { 482 }
sub ERR_CANTKILLSERVER    () { 483 }
sub ERR_NOOPERHOST        () { 491 }
sub ERR_UMODEUNKNOWNFLAG  () { 501 }
sub ERR_USERSDONTMATCH    () { 502 }

# COMMAND REPLIES
sub RPL_NONE            () { 300 }
sub RPL_USERHOST        () { 302 }
sub RPL_ISON            () { 303 }
sub RPL_AWAY            () { 301 }
sub RPL_UNAWAY          () { 305 }
sub RPL_NOWAWAY         () { 306 }
sub RPL_WHOISUSER       () { 311 }
sub RPL_WHOISSERVER     () { 312 }
sub RPL_WHOISOPERATOR   () { 313 }
sub RPL_WHOISIDLE       () { 317 }
sub RPL_ENDOFWHOIS      () { 318 }
sub RPL_WHOISCHANNELS   () { 319 }
sub RPL_WHOWASUSER      () { 314 }
sub RPL_ENDOFWHOWAS     () { 369 }
sub RPL_LISTSTART       () { 321 }
sub RPL_LIST            () { 322 }
sub RPL_LISTEND         () { 323 }
sub RPL_CHANNELMODEIS   () { 324 }
sub RPL_NOTOPIC         () { 331 }
sub RPL_TOPIC           () { 332 }
sub RPL_INVITING        () { 341 }
sub RPL_SUMMONING       () { 342 }
sub RPL_VERSION         () { 351 }
sub RPL_WHOREPLY        () { 352 }
sub RPL_ENDOFWHO        () { 315 }
sub RPL_NAMEREPLY       () { 353 }
sub RPL_ENDOFNAMES      () { 366 }
sub RPL_LINKS           () { 364 }
sub RPL_ENDOFLINKS      () { 365 }
sub RPL_BANLIST         () { 367 }
sub RPL_ENDOFBANLIST    () { 368 }
sub RPL_INFO            () { 371 }
sub RPL_ENDOFINFO       () { 374 }
sub RPL_MOTDSTART       () { 375 }
sub RPL_MOTD            () { 372 }
sub RPL_ENDOFMOTD       () { 376 }
sub RPL_YOUREOPER       () { 381 }
sub RPL_REHASHING       () { 382 }
sub RPL_TIME            () { 391 }
sub RPL_USERSSTART      () { 392 }
sub RPL_USERS           () { 393 }
sub RPL_ENDOFUSERS      () { 394 }
sub RPL_NOUSERS         () { 395 }
sub RPL_TRACELINK       () { 200 }
sub RPL_TRACECONNECTING () { 201 }
sub RPL_TRACEHANDSHAKE  () { 202 }
sub RPL_TRACEUNKNOWN    () { 203 }
sub RPL_TRACEOPERATOR   () { 204 }
sub RPL_TRACEUSER       () { 205 }
sub RPL_TRACESERVER     () { 206 }
sub RPL_TRACENEWTYPE    () { 208 }
sub RPL_TRACELOG        () { 261 }
sub RPL_STATSLINKINFO   () { 211 }
sub RPL_STATSCOMMANDS   () { 212 }
sub RPL_STATSCLINE      () { 213 }
sub RPL_STATSNLINE      () { 214 }
sub RPL_STATSILINE      () { 215 }
sub RPL_STATSKLINE      () { 216 }
sub RPL_STATSYLINE      () { 218 }
sub RPL_ENDOFSTATS      () { 219 }
sub RPL_STATSLLINE      () { 241 }
sub RPL_STATSUPTIME     () { 242 }
sub RPL_STATSOLINE      () { 243 }
sub RPL_STATSHLINE      () { 244 }
sub RPL_UMODEIS         () { 221 }
sub RPL_LUSERCLIENT     () { 251 }
sub RPL_LUSEROP         () { 252 }
sub RPL_LUSERUNKNOWN    () { 253 }
sub RPL_LUSERCHANNELS   () { 254 }
sub RPL_LUSERME         () { 255 }
sub RPL_ADMINME         () { 256 }
sub RPL_ADMINLOC1       () { 257 }
sub RPL_ADMINLOC2       () { 258 }
sub RPL_ADMINEMAIL      () { 259 }

# RESERVED
sub RPL_TRACECLASS      () { 209 }
sub RPL_STATSQLINE      () { 217 }
sub RPL_SERVICEINFO     () { 231 }
sub RPL_ENDOFSERVICES   () { 232 }
sub RPL_SERVICE         () { 233 }
sub RPL_SERVLIST        () { 234 }
sub RPL_SERVICELISTEND  () { 235 }
sub RPL_WHOISCHANOP     () { 316 }
sub RPL_KILLDONE        () { 361 }
sub RPL_CLOSING         () { 362 }
sub RPL_CLOSEEND        () { 363 }
sub RPL_INFOSTART       () { 373 }
sub RPL_MYPORTIS        () { 384 }
sub ERR_YOUWILLBEBANNED () { 466 }
sub ERR_BADCHANMASK     () { 476 }
sub ERR_NOSERVICEHOST   () { 492 }

our (%format) = (
    # WELCOME
    RPL_WELCOME          , ":Welcome to the Internet Relay Network, %s"    ,
    RPL_YOURHOST         , ":Your host is %s, running on glorious steam"   ,
    RPL_CREATED          , ":This server was created on %s"                ,
    RPL_MYINFO           , ":%s %s +%s +%s"                                ,
    RPL_BOUNCE           , ":Try server %s, port %d"                       ,

    # ERRORS
    ERR_NOSUCHNICK       , "%s :No such nick/channel"                      ,
    ERR_NOSUCHSERVER     , "%s :No such server"                            ,
    ERR_NOSUCHCHANNEL    , "%s :No such channel"                           ,
    ERR_CANNOTSENDTOCHAN , "%s :Cannot send to channel"                    ,
    ERR_TOOMANYCHANNELS  , "%s :You have joined too many channels"         ,
    ERR_WASNOSUCHNICK    , "%s :There was no such nickname"                ,
    ERR_TOOMANYTARGETS   , "%s :Duplicate recipients. No message delivered",
    ERR_NOORIGIN         , ":No origin specified"                          ,
    ERR_NORECIPIENT      , ":No recipient given (%s)"                      ,
    ERR_NOTEXTTOSEND     , ":No text to send"                              ,
    ERR_NOTOPLEVEL       , "%s :No toplevel domain specified"              ,
    ERR_WILDTOPLEVEL     , "%s :Wildcard in toplevel domain"               ,
    ERR_UNKNOWNCOMMAND   , "%s :Unknown command"                           ,
    ERR_NOMOTD           , ":MOTD File is missing"                         ,
    ERR_NOADMININFO      , "%s :No administrative info available"          ,
    ERR_FILEERROR        , ":File error doing %s on %s"                    ,
    ERR_NONICKNAMEGIVEN  , ":No nickname given"                            ,
    ERR_ERRONEOUSNICKNAME, "%s :Erroneous nickname"                        ,
    ERR_NICKNAMEINUSE    , "%s :Nickname is already in use"                ,
    ERR_NICKCOLLISION    , "%s :Nickname collision KILL"                   ,
    ERR_USERNOTINCHANNEL , "%s %s :They aren't on that channel"            ,
    ERR_NOTONCHANNEL     , "%s :You're not on that channel"                ,
    ERR_USERONCHANNEL    , "%s %s :is already on channel"                  ,
    ERR_NOLOGIN          , "%s :User not logged in"                        ,
    ERR_SUMMONDISABLED   , ":SUMMON has been disabled"                     ,
    ERR_USERSDISABLED    , ":USERS has been disabled"                      ,
    ERR_NOTREGISTERED    , ":You have not registered"                      ,
    ERR_NEEDMOREPARAMS   , "%s :Not enough parameters"                     ,
    ERR_ALREADYREGISTERED, ":You may not reregister"                       ,
    ERR_NOPERMFORHOST    , ":Your host isn't among the privileged"         ,
    ERR_PASSWDMISTMATCH  , ":Password incorrect"                           ,
    ERR_YOUREBANNEDCREEP , ":You are banned from this server"              ,
    ERR_KEYSET           , "%s :Channel key already set"                   ,
    ERR_CHANNELISFULL    , "%s :Cannot join channel (+l)"                  ,
    ERR_UNKNOWNMODE      , "%s :is unknown mode char to me"                ,
    ERR_INVITEONLYCHAN   , "%s :Cannot join channel (+i)"                  ,
    ERR_BANNEDFROMCHAN   , "%s :Cannot join channel (+b)"                  ,
    ERR_BADCHANNELKEY    , "%s :Cannot join channel (+k)"                  ,
    ERR_NOPRIVILEGES     , ":Permission Denied-You're not an IRC operator" ,
    ERR_CHANOPRIVSNEEDED , "%s :You're not channel operator"               ,
    ERR_CANTKILLSERVER   , ":You cant kill a server!"                      ,
    ERR_NOOPERHOST       , "No O-lines for your host"                      ,
    ERR_UMODEUNKNOWNFLAG , ":Unknown MODE flag"                            ,
    ERR_USERSDONTMATCH   , ":Cant change mode for other users"             ,

    # COMMAND REPLIES
    RPL_NONE            , ""                                               ,
    RPL_USERHOST        , ":%s"                                            ,
    RPL_ISON            , ":%s"                                            ,
    RPL_AWAY            , "%s :%s"                                         ,
    RPL_UNAWAY          , ":You are no longer marked as being away"        ,
    RPL_NOWAWAY         , ":You have been marked as being away"            ,
    RPL_WHOISUSER       , "%s %s %s * :%s"                                 ,
    RPL_WHOISSERVER     , "%s %s :%s"                                      ,
    RPL_WHOISOPERATOR   , "%s :is an IRC operator"                         ,
    RPL_WHOISIDLE       , "%s %d :seconds idle"                            ,
    RPL_ENDOFWHOIS      , "%s :End of /WHOIS list"                         ,
    RPL_WHOISCHANNELS   , "%s :%s"                                         ,
    RPL_WHOWASUSER      , "%s %s %s * :%s"                                 ,
    RPL_ENDOFWHOWAS     , "%s :End of WHOWAS"                              ,
    RPL_LISTSTART       , "Channel :Users Name"                            ,
    RPL_LIST            , "%s %d :%s"                                      ,
    RPL_LISTEND         , ":End of /LIST"                                  ,
    RPL_CHANNELMODEIS   , "%s %s"                                          ,
    RPL_NOTOPIC         , "%s :No topic is set"                            ,
    RPL_TOPIC           , "%s :%s"                                         ,
  # channel nick
    RPL_INVITING        , "%s %s"                                          ,
    RPL_SUMMONING       , "%s :Summoning user to IRC"                      ,
  # version.debuglevel server :comments
    RPL_VERSION         , "%d.%d %s :%s"                                   ,
  # channel user host server nick <H|G>[*][@|+] :hopcount realname
    RPL_WHOREPLY        , "%s %s %s %s %s H :0 %s"                         ,
    RPL_ENDOFWHO        , "%s :End of /WHO list"                           ,
    RPL_NAMEREPLY       , "= %s :%s"                                       ,
    RPL_ENDOFNAMES      , "%s :End of /NAMES"                              ,
    RPL_LINKS           , "%s %s :%d %s"                                   ,
    RPL_ENDOFLINKS      , "%s :End of /LINKS list"                         ,
    RPL_BANLIST         , "%s %s"                                          ,
    RPL_ENDOFBANLIST    , "%s :End of channel ban list"                    ,
    RPL_INFO            , ":%s"                                            ,
    RPL_ENDOFINFO       , ":End of /INFO list"                             ,
    RPL_MOTDSTART       , ":- %s Message of the day - "                    ,
    RPL_MOTD            , ":- %s"                                          ,
    RPL_ENDOFMOTD       , ":End of /MOTD command"                          ,
    RPL_YOUREOPER       , ":You are now an IRC operator"                   ,
    RPL_REHASHING       , "%s :Rehashing"                                  ,
    RPL_TIME            , "%s :%s"                                         ,
    RPL_USERSSTART      , ":UserID Terminal Host"                          ,
    RPL_USERS           , "%-9s %-9s %-8s"                                 ,
    RPL_ENDOFUSERS      , ":End of users"                                  ,
    RPL_NOUSERS         , ":Nobody logged in"                              ,
    RPL_TRACELINK       , "Link %d.%d %s %s"                               ,
    RPL_TRACECONNECTING , "Try. %s %s"                                     ,
    RPL_TRACEHANDSHAKE  , "H.S. %s %s"                                     ,
    RPL_TRACEUNKNOWN    , "???? %s %s"                                     ,
    RPL_TRACEOPERATOR   , "Oper %s %s"                                     ,
    RPL_TRACEUSER       , "User %s %s"                                     ,
    RPL_TRACESERVER     , "Serv %s %dS %dC %s %s!%s@%s"                    ,
    RPL_TRACENEWTYPE    , "%s 0 %s"                                        ,
    RPL_TRACELOG        , "File %s %d"                                     ,
    RPL_STATSLINKINFO   , "%s %d %d %d %d %d %s"                           ,
    RPL_STATSCOMMANDS   , "%s %s"                                          ,
    RPL_STATSCLINE      , "C %s * %s %d %s"                                ,
    RPL_STATSNLINE      , "N %s * %s %d %s"                                ,
    RPL_STATSILINE      , "I %s * %s %d %s"                                ,
    RPL_STATSKLINE      , "K %s * %s %d %s"                                ,
    RPL_STATSYLINE      , "Y %s %d %d %d"                                  ,
    RPL_ENDOFSTATS      , "%s :End of /STATS report"                       ,
    RPL_STATSLLINE      , "L %s * %s %d"                                   ,
    RPL_STATSUPTIME     , ":Server up %d days %d:%02d:%02d"                ,
    RPL_STATSOLINE      , "O %s * %s"                                      ,
    RPL_STATSHLINE      , "H %s * %s"                                      ,
    RPL_UMODEIS         , "%s"                                             ,
    RPL_LUSERCLIENT     , ":There are %d users and %d invisible on %d " .
                           "servers"                                        ,
    RPL_LUSEROP         , "%d :operator(s) online"                         ,
    RPL_LUSERUNKNOWN    , "%d :unknown connection(s)"                      ,
    RPL_LUSERCHANNELS   , "%d :channels formed"                            ,
    RPL_LUSERME         , ":I have %d clients and %d servers"              ,
    RPL_ADMINME         , "%s :Administrative info"                        ,
    RPL_ADMINLOC1       , ":%s"                                            ,
    RPL_ADMINLOC2       , ":%s"                                            ,
    RPL_ADMINEMAIL      , ":%s"                                            ,

    # RESERVED,
    RPL_TRACECLASS      , ""                                               ,
    RPL_STATSQLINE      , ""                                               ,
    RPL_SERVICEINFO     , ""                                               ,
    RPL_ENDOFSERVICES   , ""                                               ,
    RPL_SERVICE         , ""                                               ,
    RPL_SERVLIST        , ""                                               ,
    RPL_SERVICELISTEND  , ""                                               ,
    RPL_WHOISCHANOP     , ""                                               ,
    RPL_KILLDONE        , ""                                               ,
    RPL_CLOSING         , ""                                               ,
    RPL_CLOSEEND        , ""                                               ,
    RPL_INFOSTART       , ""                                               ,
    RPL_MYPORTIS        , ""                                               ,
    ERR_YOUWILLBEBANNED , ""                                               ,
    ERR_BADCHANMASK     , ""                                               ,
    ERR_NOSERVICEHOST   , ""                                               ,
);

sub import {
    my ($self) = shift;
    my ($caller) = (caller)[0];

    {  
        no strict 'refs';

        foreach my $numeric (@_) {
            my ($code) = *{ $numeric }{CODE};
            die "couldn't find $numeric!" unless $code;

            *{ "$caller\::$numeric" } = $code;
        }
    } 
}

1;
