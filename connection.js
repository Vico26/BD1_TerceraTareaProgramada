const { request } = require('http');
const sql=require('mssql');

const config={
    user:'admin_viewer',
    password:'c0nTr4S3nNi1a',
    server:'25.50.124.70',
    database:'Empresa3',
    options:{
        encrypt:true,
        trustServerCertificate:true,
        connectionTimeout:30000,
        requestTimeout:30000
    }
};

module.exports={sql,config};