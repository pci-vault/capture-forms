module.exports = {
    rewrite: [
        {
            from: '/pcd/(.*)',
            to: '$1'
        },
        {
            from: '/v1/(.*)',
            to: 'https://api-stage.pcivault.io/v1/$1'
        },
    ]
}
