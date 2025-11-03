\l aws.s3.q

.util.pathToString:{
  1_string x
 }

\l missing_funcs.q

HOME_DIR:`:.
S3_HDB_LOCAL_DIR:.Q.dd[HOME_DIR;`s3_hdb]
TMP_HDB_DIR:.Q.dd[HOME_DIR;`s3_hdb_tmp]
S3_BUCKET:hsym `$"s3://microservices-data-db"   // get from par.txt? 
S3_BUCKET_DB:.Q.dd[S3_BUCKET;`db]

DATE:.z.d - 2

// @desc save to disk
//
// @param db   {symb}         DB dir
// @param dt   {date}         Date
// @param tn   {symb}         Table name
// @param sc   {symb|symb[]}  Sort cols
//
// @return     {hsym}  
//  
// @example saveTable[`:s3_hdb;.z.d;`tab;`sym`time]
//
saveTable:{[db;symdir;dt;tn;sc] .Q.dd[.Q.par[db;dt;tn];`] set .Q.en[symdir;] ![sc xasc get tn;();0b;(enlist first sc)!enlist(#;enlist`p;first sc)]}
// saveTable:{[db;dt;tn;sc] .Q.dd[.Q.par[db;dt;tn];`] set .Q.en[db;] ![sc xasc get tn;();0b;(enlist first sc)!enlist(#;enlist`p;first sc)]}


// generate sample data
genData:{
  N:100000;
  :([]time:"p"$("p"$DATE) + 1e9*til N; sym:N?`IBM`AAPL`GOOG; price:N?100f; size:N?1000i)
  }


// Back up sym file to S3
// @example: .api.eod.backUpSym[.Q.dd[S3_HDB_LOCAL_DIR;`sym];.Q.dd[S3_BUCKET;`sym]]z
.api.eod.backUpSym:{[src;dst]
  src:.util.pathToString[src];
  dst:.util.pathToString[dst];
  .log.out[.z.h;"Backing up sym file to S3: ",src," to destination: ",dst;()];
  .aws.s3.run[`cp;`source`destination!(src;dst);""];
  }

EOD_FUNC:{[dt;t]
  .log.out[.z.h;"EOD Function started for date: ",string dt;()];

  saveTable[TMP_HDB_DIR;S3_HDB_LOCAL_DIR;dt;t;`sym`time];

  sourceDir:.util.pathToString sourceDirH:.Q.dd[TMP_HDB_DIR;dt];
  .aws.s3.run[`cp;`source`destination!(sourceDir;.util.pathToString .Q.dd[S3_BUCKET_DB;dt]);"--recursive"];
  .api.eod.backUpSym[.Q.dd[S3_HDB_LOCAL_DIR;`sym];.Q.dd[S3_BUCKET;`sym]];

  .log.out[.z.h;"Removing dir: ",sourceDir;()];
  .utils.rmdir sourceDirH;

  .log.out[.z.h;"Resetting table: ",(string t);()];
  @[`.;t;@[;`sym;`g#]0#];      // .[t;();:;.ds.schema[t]]; 

  .utils.hdb.reload[`::5000; 0b];

  .log.out[.z.h;"EOD Function completed for date: ",string dt;()];
 }





trade:genData[]

EOD_FUNC[DATE;`trade]

// exit 0