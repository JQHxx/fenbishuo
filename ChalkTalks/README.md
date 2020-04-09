
#### **说明**

本文档旨在提高项目规范化，提高代码质量以及可读性，减低协作难度。

未做特殊说明的地方，编码风格统一遵循社区最热门的代码指南：

[Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)

[Objective-C Style Guide](https://github.com/raywenderlich/objective-c-style-guide)

以下部分规范仅适用于Swift。

#### **基础**

1. 每个函数都应尽量保持其独立和简洁，一个函数只做一件事。

2. 凡是能提前返回的逻辑判断，guard总是优先于if。（Swift）

3. 每个源码文件尽量不要超过600行。

4. 除非上下文简单明确不会为空，否则不要使用强制解包类型`!`。（Swift）

5. 代码逻辑块之间保持合适的留空，方便阅读。

6. 分支逻辑嵌套尽量不要超过3层。

7. 尽量避免在代码中直接使用JSON对象，保持简洁优雅的Model设计。

8. git pull代码时尽量使用rebase代替merge，保持commit logs的干净整洁，如果不熟悉rebase，在处理冲突的时候可以使用merge。

9. git commit尽量遵循社区接受度最高的[Angular提交规范](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit-message-format)。

#### **命名**

1. OC代码统一以CT前缀命名，Swift代码不用添加任何前缀。

2. 文件夹统一遵循大写字母开头驼峰命名。

3. 图片资源命名风格遵循`模块名_业务模块_功能块_xxx_xxx`，统一使用小写字符。

#### **权限控制**（Swift）

1. 良好的权限控制不仅让代码组织更加清晰，也有利于编译速度。

2. 尽量以`private`, `fileprivate`来修饰方法和属性。

3. 不需要导出给外部使用的业务模块代码，不要加`open`，`public`修饰。

#### **注释**

1. 注释总是多多益善，但是要保证简单明确，不要有冗余和奇葩内容。

2. 所有自定义Type前都需要加完整注释。
