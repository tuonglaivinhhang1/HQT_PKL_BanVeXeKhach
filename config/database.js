const config = {
    user: 'sa',
    password: 'lamtac21',
    server: 'localhost\\SQLEXPRESS',
    database: 'PHUONGTRANG',
    stream: true,
    options: {
		encrypt: true // Use this if you're on Windows Azure
	},
    pool: {
        max: 100,
        min: 0,
        idleTimeoutMillis: 30000
    }
}

module.exports=config;
