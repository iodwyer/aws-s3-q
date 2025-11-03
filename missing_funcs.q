if[not `log in key `;
    .log.out:.log.err:.log.debug:{[level;msg;args] -1 "[" ,string[.z.p] ,"] ### ",string[level]," ### " ,msg," ### ", .Q.s1[args]}
 ]

if[not `trp in key `;
    .trp.execute:{[funcList;onError] @[funcList[0];funcList[1]; onError]}
    ]

if[not `rmdir in key `utils;
  .utils.rmdir:{[dir]
      dir:.util.pathToString dir;
      .log.out[.z.h;"Removing directory: ",dir;()];
      system "rm -rf ",dir;
 }
  ] 

if[not `hdb in key `utils;
  .utils.hdb.reload:{[addr;opt]
      .log.out[.z.h;"Reloading HDB from addr: ",string addr;()];
      addr "\\l ." 
  }
  ]