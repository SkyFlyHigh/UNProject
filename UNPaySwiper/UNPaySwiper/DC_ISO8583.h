//
//  ISO8583.h
//  DCDeviceBlueAPI
//
//  Created by Leo on 14/11/18.
//  Copyright (c) 2014年 Leo. All rights reserved.
//

#ifndef DCDeviceBlueAPI_ISO8583_h
#define DCDeviceBlueAPI_ISO8583_h

typedef struct DC_ISO8583
{
    int bit_flag; /*域数据类型0 -- string, 1 -- int, 2 -- binary*/
    char *data_name; /*域名*/
    int length; /*数据域长度*/
    int length_in_byte;/*实际长度（如果是变长）*/
    int variable_flag; /*是否变长标志0：否 2：2位变长, 3：3位变长*/
    int datatyp; /*0 -- BCD, 1 -- ASCII, 2 -- BINARY*/
    char *data; /*存放具体值*/
    char *attribute; /*保留*/
} DC_ISO8583;

DC_ISO8583 Tbl8583[128] =
{
    /* FLD 1 位图(Bit Map) - 基本位图和扩展位图*/
    {0,(char *)"BIT MAP,EXTENDED ", 8, 0, 0, 2, NULL,0},
    /* FLD 2 主帐号(Primary Account Number ) */
    {0,(char *)"PRIMARY ACCOUNT NUMBER ", 22, 0, 2, 0, NULL, 0},
    /* FLD 3 处理代码 （Processing Code ) */
    {0,(char *)"PROCESSING CODE ", 6, 0, 0, 0, NULL, 0},
    /* FLD 4 交易金额 （Amount, Transaction) */
    {0,(char *)"AMOUNT, TRANSACTION ", 12, 0, 0, 0, NULL, 0},
    /* FLD 5 */
    {0,(char *)"NO USE ", 12, 0, 0, 0, NULL,0},
    /* FLD 6 */
    {0,(char *)"NO USE ", 12, 0, 0, 0, NULL,0},
    /* FLD 7 交易日期和时间 Transmission Date and Time */
    {0,(char *)"TRANSACTION DATE AND TIME ", 10, 0, 0, 0, NULL,0},
    /* FLD 8 */
    {0,(char *)"NO USE ", 8, 0, 0, 0, NULL,0},
    /* FLD 9 */
    {0,(char *)"NO USE ", 8, 0, 0, 0, NULL,0},
    /* FLD 10 */
    {0,(char *)"NO USE ", 8, 0, 0, 0, NULL,0},
    /* FLD 11 系统跟踪号（Systems Trace Audit Number) */
    {0,(char *)"SYSTEM TRACE AUDIT NUMBER ", 6, 0, 0, 0, NULL,0},
    /* FLD 12 本地交易时间（Time ,Local Transaction）*/
    {0,(char *)"TIME, LOCAL TRANSACTION ", 6, 0, 0, 0, NULL,0},
    /* FLD 13 本地交易日期(Date ,Local Transaction) */
    {0,(char *)"DATE, LOCAL TRANSACTION ", 4, 0, 0, 0, NULL,0},
    /* FLD 14 有效期(Date ,Expiration) */
    {0,(char *)"DATE, EXPIRATION ", 4, 0, 0, 0, NULL,0},
    /* FLD 15 结算日期(Date ,Settlement) */
    {0,(char *)"DATE, SETTLEMENT ", 4, 0, 0, 0, NULL,0},
    /* FLD 16 */
    {0,(char *)"NO USE ", 4, 0, 0, 0, NULL,0},
    /* FLD 17 获取日期(Date ,Capture) */
    {0,(char *)"DATE, CAPTURE ", 4, 0, 0, 0, NULL,0},
    /* FLD 18 商户类型（Merchant's Type) */
    {0,(char *)"MERCHANT'S TYPE ", 4, 0, 0, 0, NULL,0},
    /* FLD 19 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 20 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 21 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 22 服务点输入方式(Point-of-Service Entry Mode) */
    {0,(char *)"POINT OF SERVICE ENTRY MODE ", 3, 0, 0, 0, NULL,0},
    /* FLD 23 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 24 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 25 服务点条件代码(Point-of-Service Condition Code) */
    {0,(char *)"POINT OF SERVICE CONDITION CODE ", 2, 0, 0, 0, NULL,0},
    /* FLD 26 */
    {0,(char *)"NO USE ", 2, 0, 0, 0, NULL,0},
    /* FLD 27 */
    {0,(char *)"NO USE ", 1, 0, 0, 0, NULL,0},
    /* FLD 28 */
    {0,(char *)"NO USE ", 6, 0, 0, 0, NULL,0},
    /* FLD 29 */
    {0,(char *)"NO USE ", 8, 0, 1, 0, NULL,0},
    /* FLD 30 */
    {0,(char *)"NO USE ", 8, 0, 1, 0, NULL,0},
    /* FLD 31 */
    {0,(char *)"NO USE ", 8, 0, 1, 0, NULL,0},
    /* FLD 32 收单机构标识码(Acquirer institution Identification) */
    {0,(char *)"ACQUIRER INSTITUTION ID. CODE ", 11, 0, 2, 0, NULL,0},
    /* FLD 33 向前机构标识码(Forwarding Institution Identification Code)*/
    {0,(char *)"FORWARDING INSTITUTION ID. CODE ", 11, 0, 2, 0, NULL,0},
    /* FLD 34 */
    {0,(char *)"NO USE ", 28, 0, 2, 0, NULL,0},
    /* FLD 35 二磁道数据(Track 2 Data) */
    {0,(char *)"TRACK 2 DATA ", 37, 0, 2, 0, NULL,0},
    /* FLD 36 三磁道数据(Track 3 Data) */
    {0,(char *)"TRACK 3 DATA ",104, 0, 3, 0, NULL,0},
    /* FLD 37 检索索引号(Retrieval Reference Number) */
    {0,(char *)"RETRIEVAL REFERENCE NUMBER ", 12, 0, 0, 1, NULL,0},
    /* FLD 38 授权码(Authorization Identification) */
    {0,(char *)"AUTH. IDENTIFICATION RESPONSE ", 6, 0, 0, 1, NULL,0},
    /* FLD 39 返回码(Response Code) */
    {0,(char *)"RESPONSE CODE ", 2, 0, 0, 1, NULL,0},
    /* FLD 40 */
    {0,(char *)"NO USE ", 3, 0, 0, 1, NULL,0},
    /* FLD 41 收卡单位终端标识码(Card Acceptor Terminal Identification) */
    {0,(char *)"CARD ACCEPTOR TERMINAL ID. ", 8, 0, 0, 1, NULL,0},
    /* FLD 42 收卡商户定义码(Card Acceptor Identification Code) */
    {0,(char *)"CARD ACCEPTOR IDENTIFICATION CODE ", 15, 0, 0, 1, NULL,0},
    /* FLD 43 收卡商户位置(Card Acceptor Location) */
    {0,(char *)"CARD ACCEPTOR NAME LOCATION ", 40, 0, 0, 0, NULL,0},
    /* FLD 44 附加返回数据(Additional ResponseData) */
    {0,(char *)"ADDITIONAL RESPONSE DATA ", 25, 0, 2, 1, NULL,0},
    /* FLD 45 */
    {0,(char *)"TRACK 1 DATA ", 76, 0, 2, 0, NULL,0},
    /* FLD 46 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 47 */
    {0,(char *)"field47 ",999, 0, 3, 0, NULL,0},
    /* FLD 48 附加数据-私用(Additional Data-Private) */
    {0,(char *)"ADDITIONAL DATA --- PRIVATE ",999, 0, 3, 0, NULL,0},
    /* FLD 49 交易货币代码(Currency Code,Transaction) */
    {0,(char *)"CURRENCY CODE,TRANSACTION ", 3, 0, 0, 1, NULL,0},
    /* FLD 50 结算货币代码(Currency Code,Settlement) */
    {0,(char *)"CURRENCY CODE,SETTLEMENT ", 3, 0, 0, 0, NULL,0},
    /* FLD 51 */
    {0,(char *)"NO USE ", 3, 0, 0, 0, NULL,0},
    /* FLD 52 用户密码(PIN)数据(PIN Data) */
    {0,(char *)"PERSONAL IDENTIFICATION NUMBER DATA ", 8, 0, 0, 2, NULL,0},
    /* FLD 53 密码相关控制信息(Security Related Control) */
    {0,(char *)"SECURITY RELATED CONTROL INformATION", 16, 0, 0, 0, NULL,0},
    /* FLD 54 附加金额(Additional Amounts) */
    {0,(char *)"ADDITIONAL AMOUNTS ",120, 0, 3, 1, NULL,0},
    /* FLD 55 */
    {0,(char *)"NO USE ",999, 0, 3, 2, NULL,0},
    /* FLD 56 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 57 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 58 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 59 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 60 */
    {0,(char *)"NO USE ", 5, 0, 3, 0, NULL,0},
    /* FLD 61 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 62 */
    {0,(char *)"NO USE ", 11, 0, 3, 1, NULL,0},
    /* FLD 63 */
    {0,(char *)"NO USE ", 11, 0, 3, 1, NULL,0},
    /* FLD 64 信息确认码(MAC) */
    {0,(char *)"MESSAGE AUTHENTICATION CODE FIELD ", 8, 0, 0, 2, NULL,0},
    /* FLD 65 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 66 */
    {0,(char *)"NO USE ", 1, 0, 0, 0, NULL,0},
    /* FLD 67 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 68 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 69 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 70 管理信息码(System Management Indormation Code)*/
    {0,(char *)"SYSTEM MANAGEMENT INformATION CODE ", 3, 0, 0, 0, NULL,0},
    /* FLD 71 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 72 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 73 */
    {0,(char *)"NO USE ", 6, 0, 0, 0, NULL,0},
    /* FLD 74 贷记交易笔数(Transaction Number) */
    {0,(char *)"NUMBER OF CREDITS ", 10, 0, 0, 0, NULL,0},
    /* FLD 75 贷记自动冲正交易笔数(Credits,Reversal Number) */
    {0,(char *)"REVERSAL NUMBER OF CREDITS ", 10, 0, 0, 0, NULL,0},
    /* FLD 76 借记交易笔数(Debits,Number) */
    {0,(char *)"NUMBER OF DEBITS ", 10, 0, 0, 0, NULL,0},
    /* FLD 77 借记自动冲正交易笔数(Debits,Reversal Number) */
    {0,(char *)"REVERSAL NUMBER OF DEBITS ", 10, 0, 0, 0, NULL,0},
    /* FLD 78 转帐交易笔数(Transfers,Number) */
    {0,(char *)"NUMBER OF TRANSFER ", 10, 0, 0, 0, NULL,0},
    /* FLD 79 转帐自动冲正交易笔数(Transfers,Reversal Number) */
    {0,(char *)"REVERSAL NUMBER OF TRANSFER ", 10, 0, 0, 0, NULL,0},
    /* FLD 80 查询交易笔数(Inquiries,Number) */
    {0,(char *)"NUMBER OF INQUIRS ", 10, 0, 0, 0, NULL,0},
    /* FLD 81 授权交易笔数(Authorization,Number) */
    {0,(char *)"AUTHORIZATION NUMBER ", 10, 0, 0, 0, NULL,0},
    /* FLD 82 */
    {0,(char *)"NO USE ", 12, 0, 0, 0, NULL,0},
    /* FLD 83 贷记交易费金额(Credits,Transaction FeeAmount) */
    {0,(char *)"CREDITS,TRANSCATION FEEAMOUNT ", 12, 0, 0, 0, NULL,0},
    /* FLD 84 */
    {0,(char *)"NO USE ", 12, 0, 0, 0, NULL,0},
    /* FLD 85 借记交易费金额(Debits,Transaction FeeAmount) */
    {0,(char *)"DEBITS,TRANSCATION FEEAMOUNT ", 12, 0, 0, 0, NULL,0},
    /* FLD 86 贷记交易金额(Credits,Amount) */
    {0,(char *)"AMOUNT OF CREDITS ", 16, 0, 0, 0, NULL,0},
    /* FLD 87 贷记自动冲正金额(Credits,Reversal Amount) */
    {0,(char *)"REVERSAL AMOUNT OF CREDITS ", 16, 0, 0, 0, NULL,0},
    /* FLD 88 借记交易金额(Debits,Amount) */
    {0,(char *)"AMOUNT OF DEBITS ", 16, 0, 0, 0, NULL,0},
    /* FLD 89 借记自动冲正交易金额(Debits,Reversal Amount) */
    {0,(char *)"REVERSAL AMOUNT OF DEBITS ", 16, 0, 0, 0, NULL,0},
    /* FLD 90 原交易的数据元素(Original Data Elements) */
    {0,(char *)"ORIGINAL DATA ELEMENTS ", 42, 0, 0, 0, NULL,0},
    /* FLD 91 文件修改编码(File Update Code) */
    {0,(char *)"FILE UPDATE CODE ", 1, 0, 0, 0, NULL,0},
    /* FLD 92 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 93 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 94 服务指示码(Service Indicator) */
    {0,(char *)"SERVICE INDICATOR ", 7, 0, 0, 0, NULL,0},
    /* FLD 95 代替金额(Replacement Amounts) */
    {0,(char *)"REPLACEMENT AMOUNTS ", 42, 0, 0, 0, NULL,0},
    /* FLD 96 */
    {0,(char *)"NO USE ", 8, 0, 0, 0, NULL,0},
    /* FLD 97 净结算金额(Net Settlement Amount) */
    {0,(char *)"AMOUNT OF NET SETTLEMENT ", 16, 0, 0, 0, NULL,0},
    /* FLD 98 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 99 结算机构码(Settlement Institution Identification)*/
    {0,(char *)"SETTLEMENT INSTITUTION ID ", 11, 0, 2, 0, NULL,0},
    /* FLD 100 接收机构码（Receiving Institution Identification) */
    {0,(char *)"RECVEING INSTITUTION ID ", 11, 0, 2, 0, NULL,0},
    /* FLD 101 文件名(FileName) */
    {0,(char *)"FILENAME ", 17, 0, 2, 0, NULL,0},
    /* FLD 102 帐号1(Account Identification1) */
    {0,(char *)"ACCOUNT IDENTIFICATION1 ", 28, 0, 2, 0, NULL,0},
    /* FLD 103 帐号2(Account Identiication2) */
    {0,(char *)"ACCOUNT IDENTIFICATION2 ", 28, 0, 2, 0, NULL,0},
    /* FLD 104 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 105 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 106 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 107 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 108 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 109 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 110 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 111 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 112 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 113 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 114 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 115 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 116 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 117 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 118 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 119 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 120 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 121 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 122 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 123 新密码数据(New PIN Data) */
    {0,(char *)"NEW PIN DATA ", 8, 0, 3, 2, NULL,0},
    /* FLD 124 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 125 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 126 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 127 */
    {0,(char *)"NO USE ",999, 0, 3, 0, NULL,0},
    /* FLD 128 信息确认码(MAC) */
    {0,(char *)"MESSAGE AUTHENTICATION CODE FIELD ", 8, 0, 0, 2, NULL,0},
};

#endif
