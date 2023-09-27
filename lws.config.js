module.exports = {
    rewrite: [
        {
            from: '/v1/(.*)',
            to: 'https://api-stage.pcivault.io/v1/$1'
        },
    ]
}
