const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        const requestBody = JSON.parse(event.body);
        const { comment } = requestBody;
        
        const params = {
            TableName: 'travelBlogComments',
            Item: {
                commentId: Date.now().toString(),
                comment: comment
            }
        };
        
        await dynamoDB.put(params).promise();
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Comment saved successfully' })
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error saving comment' })
        };
    }
};
