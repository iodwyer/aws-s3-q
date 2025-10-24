// .trp.setMode[`trap]
// .log.cmp.setDebug[.z.h; 1b]
// .log.isdebug[]

.type.isString:{
    :10h~type x;
 };

.type.ensureString:{
    $[.type.isString x;
        :x;
        :string x
    ];
 }

.aws.s3.cli_cmd:"aws s3"           // add --profile <profile_name> if needed

/ Attempts to run a AWS S3 command 
/  @param operation (symbol) Supported options: cp|sync|mv
/  @param fileParams (dict) Source and destination parameters for the AWS S3 command
/  @param options (String) Additional AWS S3 CLI options e.g. "--recursive" 
/  @example .aws.s3.run[`cp;`source`destination!("/local/path/file.txt";"s3://bucket-name/path/file.txt");"--recursive"]
.aws.s3.run:{[operation;fileParams;options]
    .log.debug[.z.h;"AWS S3 Operation. Executing with inputs: ";`operation`params`options!(operation;fileParams;options)];
    
    if[not operation in `cp`sync`mv;
        :.log.err[.z.h;"Unsupported AWS S3 operation: ",string operation;"Exiting function"];
    ];

    CMD:" " sv .type.ensureString each (.aws.s3.cli_cmd;operation;fileParams`source;fileParams`destination;options);
    .log.out[.z.h;"Executing AWS S3 Command";CMD]; 
    .trp.execute[(system;CMD);{.log.err[.z.h;"System call failed: ",x;()]; '"SystemCallFailedException"}];
 }   
