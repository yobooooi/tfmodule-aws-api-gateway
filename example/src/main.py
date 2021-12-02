import json
import os

def healthcheck(event, context):
    environment = event['stageVariables']['stage']
    return {
        'statusCode': 200,
        'body': json.dumps({'health': 'up',
                            'version': '1.5.0',
                            'stage': '{0}'.format(environment)})
    }

def env(event, context):
    stages_vars = dict(event['stageVariables'])
    env = dict(os.environ)
    return {
        'statusCode': 200,
        'body': json.dumps({'event_vars': '{0}'.format(stages_vars),
                            'env_vars': '{0}'.format(env)})
    }
  
def post_example(event, context):
    event_body = event['body']
    return {
        'statusCode': 200,
        'body': json.dumps({'event': '{0}'.format(event_body)})
    }

if __name__ == '__main__':
    print(healthcheck({}, {}))
    print(env({}, {}))