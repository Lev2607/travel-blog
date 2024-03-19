import AWS from 'aws-sdk';

AWS.config.update({
  region: 'eu-central-1',
});

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export default async function handler(req, res) {
  if (req.method === 'GET') {
    const { postId } = req.query;

    const params = {
      TableName: 'travelBlogComments',
      KeyConditionExpression: 'PostId = :postId',
      ExpressionAttributeValues: {
        ':postId': postId,
      },
    };

    try {
      const data = await dynamoDb.query(params).promise();
      res.status(200).json(data.Items);
    } catch (error) {
      res.status(500).json({ error: 'Could not get comments' });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}