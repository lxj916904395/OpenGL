//
//  ViewController.m
//  OpenGL-ES-003-GLKBaseEffect加载图片纹理-02
//
//  Created by zhongding on 2019/1/2.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong ,nonatomic) EAGLContext *context;
@property(strong ,nonatomic) GLKBaseEffect *effect;

@property(assign ,nonatomic) int count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self setupContext];
    [self render];
}

- (void)render{
    GLfloat vertexs[] = {
        -0.5f,0.5f,0,   0.3,0.5,0.1,    1.0,0,
        0.5f,0.5f,0,    0.2,0,1,        1.0,1.0,
        -0.5f,-0.5f,0,  0.4,0.6,0.2,    1.0,0.0,
        0.5f,-0.5f,0,   0.3,0.5,0.1,    0.0,0.0,
        0,0,1,           1,1,1,          0.5,0.5
    };
    
    GLuint indexs[] = {
        
        0,1,3,
        0,3,2,
        0,2,4,
        0,4,1,
        1,3,4,
        2,4,3
    };
    
    self.count = sizeof(indexs)/sizeof(GLuint);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
    GLuint indexsBuffer;
    glGenBuffers(1, &indexsBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexsBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexs), indexs, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat*)NULL+3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat*)NULL+6);
    
    [self setupEffect];
    [self setupMatrix];
}

- (void)setupEffect{
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1",GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:file options:dict error:nil];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = info.name;
}

- (void)setupMatrix{
    CGSize size = self.view.frame.size;
    float accept = size.width/size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), accept, 1, 15.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -3);
    self.effect.transform.modelviewMatrix = modelviewMatrix;
    
}

- (void)setupContext{
    self.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.5, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    
}


- (IBAction)clickX:(id)sender {
}
- (IBAction)clickY:(id)sender {
}
- (IBAction)clickZ:(id)sender {
}

@end
