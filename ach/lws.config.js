module.exports = {
    rewrite: [
        {
            from: '/ach/(.*)',
            to: '$1'
        },
        {
            from: '/v1/(.*)',
            to: 'https://api-stage.pcivault.io/v1/$1'
        },
    ]
}
