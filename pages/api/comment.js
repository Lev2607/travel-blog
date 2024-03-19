import AWS from 'aws-sdk';

AWS.config.update({
  region: 'eu-central-1',
});

const dynamoDb = new AWS.DynamoDB.DocumentClient();

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { comment, postId } = req.body;

    const params = {
      TableName: 'travelBlogComments',
      Item: {
        'PostId': postId,
        'Comment': comment,
        'Timestamp': Date.now(),
      },
    };

    try {
      await dynamoDb.put(params).promise();
      res.status(200).json({ status: 'Comment saved' });
    } catch (error) {
      res.status(500).json({ error: 'Could not save comment' });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}