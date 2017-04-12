//
//  OPenglView.swift
//  OPenglTest
//
//  Created by Shreesha on 27/03/17.
//  Copyright © 2017 YML. All rights reserved.
//

import Foundation
import UIKit
import OpenGLES

struct Vertex {
    var Position: (Float, Float, Float)
    var Color: (Float, Float, Float, Float)
    var TexCoord: (Float, Float)
}

let TEX_COORD_MAX = 4.f

class OPenGlView: UIView {

    var eagleLayer: CAEAGLLayer?
    var eagleContext: EAGLContext?
    var colorRenderBuffer = GLuint()
    var positionSlot = GLuint()
    var colorSlot = GLuint()
    var projectionUniform = GLuint()
    var modelViewUniform = GLuint()
    var currentRotation: Float = 0
    var depthBuffer = GLuint()

    var floorTexture = GLuint()
    var fishTexture = GLuint()
    var texCoordSlot = GLuint()
    var textureUniform = GLuint()

    var vertexBuffer = GLuint()
    var indexBuffer = GLuint()
    var vertexBuffer2 = GLuint()
    var indexBuffer2 = GLuint()

    var vertices = [
        Vertex(Position: (1, -1, 0), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (1, 1, 0), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, 0), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, -1, 0), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        // Back
        Vertex(Position: (1, 1, -2), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (-1, -1, -2), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (1, -1, -2), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, -2), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        // Left
        Vertex(Position: (-1, -1, 0), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (-1, 1, 0), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, -2), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, -1, -2), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        // Right
        Vertex(Position: (1, -1, -2), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (1, 1, -2), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (1, 1, 0), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (1, -1, 0), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        // Top
        Vertex(Position: (1, 1, 0), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (1, 1, -2), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, -2), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, 1, 0), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        // Bottom
        Vertex(Position: (1, -1, -2), Color: (1, 0, 0, 1), TexCoord: (TEX_COORD_MAX, 0)),
        Vertex(Position: (1, -1, 0), Color: (0, 1, 0, 1), TexCoord: (TEX_COORD_MAX, TEX_COORD_MAX)),
        Vertex(Position: (-1, -1, 0), Color: (0, 0, 1, 1), TexCoord: (0, TEX_COORD_MAX)),
        Vertex(Position: (-1, -1, -2), Color: (0, 0, 0, 1), TexCoord: (0, 0)),
        ]

    var indices : [GLubyte] = [
        // Front
        0, 1, 2,
        2, 3, 0,
        // Back
        4, 5, 6,
        4, 5, 7,
        // Left
        8, 9, 10,
        10, 11, 8,
        // Right
        12, 13, 14,
        14, 15, 12,
        // Top
        16, 17, 18,
        18, 19, 16,
        // Bottom
        20, 21, 22,
        22, 23, 20
    ]

    var vertices2 = [
        Vertex(Position: (0.5, -0.5, 0.01), Color: (1, 1, 1, 1), TexCoord: (1, 1)),
        Vertex(Position: (0.5, 0.5, 0.01), Color: (1, 1, 1, 1), TexCoord: (1, 0)),
        Vertex(Position: (-0.5, 0.5, 0.01), Color: (1, 1, 1, 1), TexCoord: (0, 0)),
        Vertex(Position: (-0.5, -0.5, 0.01), Color: (1, 1, 1, 1), TexCoord: (0, 1)),
        ];

    var indices2 : [GLubyte] = [
        1, 0, 2, 3
    ];

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }

    private func sharedInit() {

        setupLayer()
        setupContext()
        setupDepthBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        _ = compileShaders()
        _ = setupVBOs()
        setupDisplayLink()
        floorTexture = setupTexture(name: "tile_floor.png")
        fishTexture = setupTexture(name: "item_powerup_fish.png")
    }

    deinit {
        eagleContext = nil
    }

    private func setupLayer() {
        eagleLayer = layer as? CAEAGLLayer
        eagleLayer?.isOpaque = true
    }

    private func setupContext() {
        let api : EAGLRenderingAPI = EAGLRenderingAPI.openGLES2
        eagleContext = EAGLContext(api: api)

        if (eagleContext == nil) {
            NSLog("Failed to initialize OpenGLES 2.0 context")
        }

        if (!EAGLContext.setCurrent(eagleContext!)) {
            NSLog("Failed to set current OpenGL context")
        }
    }

    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        if (eagleContext!.renderbufferStorage(Int(GL_RENDERBUFFER), from: eagleLayer!) == false) {
            NSLog("setupRenderBuffer():  renderbufferStorage() failed")
        }
    }

    private func setupFrameBuffer() {
        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER.gle, GL_DEPTH_ATTACHMENT.gle, GL_RENDERBUFFER.gle, depthBuffer)
    }

    func render(_ displayLink: CADisplayLink) {

        glBlendFunc(GL_ONE.gle, GL_ONE_MINUS_SRC_ALPHA.gle);
        glEnable(GL_BLEND.gle);

        glClearColor(0, 104.0/255, 55.0/255, 1.0)
        glClear(GL_COLOR_BUFFER_BIT.glf | GL_DEPTH_BUFFER_BIT.gle)
        glEnable(GL_DEPTH_TEST.gle)

        let projection = CC3GLMatrix.matrix() as AnyObject
        let h = 4 * frame.height / frame.width
        projection.populate(fromFrustumLeft: GLfloat(-2), andRight: GLfloat(2), andBottom: GLfloat(-h/2), andTop: GLfloat(h/2), andNear: GLfloat(4), andFar: GLfloat(10))
        glUniformMatrix4fv(GLint(projectionUniform), 1, 0, projection.glMatrix)

        let modelView = CC3GLMatrix.matrix() as AnyObject
        modelView.populate(fromTranslation: CC3Vector(x: GLfloat(sin(CACurrentMediaTime())), y: 0.gf, z: -7.gf))
        currentRotation += Float(displayLink.duration) * 90.f
        print(currentRotation)
        modelView.rotate(by: CC3VectorMake(currentRotation, currentRotation, 0))
        glUniformMatrix4fv(GLint(modelViewUniform), 1, 0, modelView.glMatrix)

        glViewport(0, 0, frame.width.glz, frame.height.glz)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer);
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer);

        let positionPointer = UnsafeRawPointer(bitPattern: 0)
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT.gle, GLboolean(GL_FALSE), GLsizei(sizeof(Vertex.self)), positionPointer)
        let colorPointer = UnsafeRawPointer(bitPattern: MemoryLayout<Float>.size * 3)
        glVertexAttribPointer(colorSlot, 4, GL_FLOAT.gle, GLboolean(GL_FALSE), GLsizei(sizeof(Vertex.self)), colorPointer)
        let vertexSlotFirstComponent = UnsafePointer<Int>(bitPattern: MemoryLayout<Float>.size * 7)
        glVertexAttribPointer(texCoordSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              GLsizei(sizeof(Vertex.self)), vertexSlotFirstComponent);


        glActiveTexture(GLenum(GL_TEXTURE0));
        glBindTexture(GLenum(GL_TEXTURE_2D), floorTexture);
        glUniform1i(GLint(textureUniform), 0);

        let vertexBufferOffset = UnsafeRawPointer(bitPattern: 0)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei((indices.count * MemoryLayout<GLubyte>.size)/MemoryLayout<GLubyte>.size),
                       GLenum(GL_UNSIGNED_BYTE), vertexBufferOffset)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer2)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer2)

        glActiveTexture(GLenum(GL_TEXTURE0));
        glBindTexture(GLenum(GL_TEXTURE_2D), fishTexture);
        glUniform1i(GLint(textureUniform), 0);

        glUniformMatrix4fv(GLint(modelViewUniform), 1, 0, (modelView as AnyObject).glMatrix);

        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), positionPointer);
        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), colorPointer);
        glVertexAttribPointer(texCoordSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), vertexSlotFirstComponent);

        glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei((indices2.count * MemoryLayout<GLubyte>.size)/MemoryLayout<GLubyte>.size), GLenum(GL_UNSIGNED_BYTE), positionPointer);

        eagleContext?.presentRenderbuffer(GL_RENDERBUFFER.i)
    }

    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(OPenGlView.render(_:)))
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }

    private func setupDepthBuffer() {
        glGenRenderbuffers(1, &depthBuffer)
        glBindRenderbuffer(GL_RENDERBUFFER.gle, depthBuffer)
        glRenderbufferStorage(GL_RENDERBUFFER.gle, GL_DEPTH_COMPONENT16.gle, frame.width.glz, frame.height.glz)

    }

    private func setupTexture(name: String) -> GLuint {
        let spriteImage = UIImage(named: name)!.cgImage!
        let width = spriteImage.width.f
        let height = spriteImage.height.f

        let spriteData = UnsafeMutableRawPointer(calloc(Int(UInt(width * height * 4)), MemoryLayout<GLubyte>.size))

        let spriteContext = CGContext(data: spriteData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: spriteImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        spriteContext?.draw(spriteImage, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))

        var textName = GLuint()

        glGenTextures(1, &textName)
        glBindTexture(GL_TEXTURE_2D.gle, textName)

        glTexParameteri(GL_TEXTURE_2D.gle, GL_TEXTURE_MIN_FILTER.gle, GLint(GL_NEAREST))

        glTexImage2D(GL_TEXTURE_2D.gle, 0, GLint(GL_RGBA), GLsizei(width), GLsizei(height), 0, GL_RGBA.gle, GL_UNSIGNED_BYTE.gle, spriteData)

        free(spriteData)
        return textName
    }
}

extension Int32 {
    var gle: GLenum {
        return GLenum(self)
    }

    var glf: GLbitfield {
        return GLbitfield(self)
    }

    var i: Int {
        return Int(self)
    }
}

extension CGFloat {
    var glz: GLsizei {
        return GLsizei(self)
    }
}

extension Int {
    var gf: GLfloat{
        return GLfloat(self)
    }

    var f: Float{
        return Float(self)
    }
}

extension OPenGlView {

    func compileShader(shaderName: String, shaderType: GLenum, shader: UnsafeMutablePointer<GLuint>) -> Int {
        let shaderPath = Bundle.main.path(forResource: shaderName, ofType:"glsl")
        var error : NSError?
        let shaderString: NSString?
        do {
            shaderString = try NSString(contentsOfFile: shaderPath!, encoding:String.Encoding.utf8.rawValue)
        } catch let error1 as NSError {
            error = error1
            shaderString = nil
        }
        if error != nil {
            NSLog("OpenGLView compileShader():  error loading shader: %@", error!.localizedDescription)
            return -1
        }

        shader.pointee = glCreateShader(shaderType)
        if (shader.pointee == 0) {
            NSLog("OpenGLView compileShader():  glCreateShader failed")
            return -1
        }
        var shaderStringUTF8 = shaderString!.utf8String
        var shaderStringLength: GLint = GLint(Int32(shaderString!.length))
        glShaderSource(shader.pointee, 1, &shaderStringUTF8, &shaderStringLength)

        glCompileShader(shader.pointee);
        var success = GLint()
        glGetShaderiv(shader.pointee, GLenum(GL_COMPILE_STATUS), &success)

        if (success == GL_FALSE) {
            let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: 256)
            var infoLogLength = GLsizei()

            glGetShaderInfoLog(shader.pointee, GLsizei(MemoryLayout<GLchar>.size * 256), &infoLogLength, infoLog)
            NSLog("OpenGLView compileShader():  glCompileShader() failed:  %@", String(cString: infoLog))

            infoLog.deallocate(capacity: 256)
            return -1
        }

        return 0
    }

    func compileShaders() -> Int {
        let vertexShader = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
        if (self.compileShader(shaderName: "SimpleVertex", shaderType: GLenum(GL_VERTEX_SHADER), shader: vertexShader) != 0 ) {
            NSLog("OpenGLView compileShaders():  compileShader() failed")
            return -1
        }

        let fragmentShader = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
        if (self.compileShader(shaderName: "SimpleFragment", shaderType: GLenum(GL_FRAGMENT_SHADER), shader: fragmentShader) != 0) {
            NSLog("OpenGLView compileShaders():  compileShader() failed")
            return -1
        }

        let program = glCreateProgram()
        glAttachShader(program, vertexShader.pointee)
        glAttachShader(program, fragmentShader.pointee)
        glLinkProgram(program)

        var success = GLint()

        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
        if (success == GL_FALSE) {
            let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: 1024)
            var infoLogLength = GLsizei()

            glGetProgramInfoLog(program, GLsizei(MemoryLayout<GLchar>.size * 1024), &infoLogLength, infoLog)
            NSLog("OpenGLView compileShaders():  glLinkProgram() failed:  %@", String(cString:  infoLog))

            infoLog.deallocate(capacity: 1024)
            fragmentShader.deallocate(capacity: 1)
            vertexShader.deallocate(capacity: 1)

            return -1
        }

        glUseProgram(program)

        positionSlot = GLuint(glGetAttribLocation(program, "Position"))
        colorSlot = GLuint(glGetAttribLocation(program, "SourceColor"))
        projectionUniform = GLuint(glGetUniformLocation(program, "Projection"))
        modelViewUniform = GLuint(glGetUniformLocation(program, "ModelviewTranslate"))
        texCoordSlot = GLuint(glGetAttribLocation(program, "TexCoordIn"))
        textureUniform = GLuint(glGetUniformLocation(program, "Texture"))


        glEnableVertexAttribArray(texCoordSlot)
        glEnableVertexAttribArray(positionSlot)
        glEnableVertexAttribArray(colorSlot)

        fragmentShader.deallocate(capacity: 1)
        vertexShader.deallocate(capacity: 1)
        return 0
    }

    func setupVBOs() -> Int {

        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), (vertices.count * MemoryLayout<Vertex>.size), vertices, GLenum(GL_STATIC_DRAW))

        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), (indices.count * MemoryLayout<GLubyte>.size), indices, GLenum(GL_STATIC_DRAW))

        // second object
        glGenBuffers(1, &vertexBuffer2)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer2)
        glBufferData(GLenum(GL_ARRAY_BUFFER), (vertices2.count * MemoryLayout<Vertex>.size), vertices2, GLenum(GL_STATIC_DRAW))

        glGenBuffers(1, &indexBuffer2)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer2)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), (indices2.count * MemoryLayout<GLubyte>.size), indices2, GLenum(GL_STATIC_DRAW))
        return 0
    }
    
}

func sizeof <T> (_ : T.Type) -> Int {
    return (MemoryLayout<T>.size)
}

func sizeof <T> (_ : T) -> Int {
    return (MemoryLayout<T>.size)
}

func sizeof <T> (_ value : [T]) -> Int {
    return (MemoryLayout<T>.size * value.count)
}
