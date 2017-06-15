const config = {
    user: 'sa',
    password: 'vuongngockim',
    server: 'localhost\\ENTERPRISE',

    database: 'PHUONGTRANG',
    stream: true,
    connectionTimeout: 300000,
    requestTimeout: 300000,
    options: {
		encrypt: true // Use this if you're on Windows Azure
	},
    pool: {
        max: 100,
        min: 0,
        idleTimeoutMillis: 300000,
    }
}

module.exports=config;
