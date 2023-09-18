import json
import os

def lambda_handler(event, context):
    # Define the file path
    efs_path = '/mnt/efs'

    try:
        # Extract content from the event or use a default message
        file_name = 'hello.txt'
        content = event.get('content', 'Hello EFS content write from Lambda!')

        # Write the content to the file
        with open(os.path.join(efs_path, file_name), 'w') as file:
            file.write(content)

        # Return a success message
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Content written to {efs_path}'
            })
        }

    except FileNotFoundError:
        # If the file is not found, return an error response
        return {
            'statusCode': 404,
            'body': 'File not found'
        }
    except Exception as e:
        # Handle any other exceptions
        return {
            'statusCode': 500,
            'body': f'An error occurred: {str(e)}'
        }
