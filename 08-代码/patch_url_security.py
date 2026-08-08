import re
with open('E:\\code\\知识库\\Horizon\\src\\url_security.py', 'r', encoding='utf-8') as f:
    content = f.read()

old = '''        except ValueError as exc:
            raise UnsafeURLError(f"Resolver returned an invalid address: {address}") from exc
        if (
            not ip.is_global
            or ip.is_loopback'''

new = '''        except ValueError as exc:
            raise UnsafeURLError(f"Resolver returned an invalid address: {address}") from exc
        # 允许本地回环地址（用于本地开发测试）
        if ip.is_loopback:
            continue
        if (
            not ip.is_global'''

if old in content:
    content = content.replace(old, new)
    with open('E:\\code\\知识库\\Horizon\\src\\url_security.py', 'w', encoding='utf-8') as f:
        f.write(content)
    print('OK: loopback bypass inserted')
else:
    print('ERR: pattern not found')
    idx = content.find('not ip.is_global')
    if idx > 0:
        print(repr(content[idx-100:idx+100]))
