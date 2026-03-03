# 测试策略

TileLang 开发中的测试方法和策略。

## 测试层次

### 1. 单元测试

**目的**: 验证单个算子的正确性

**工具**: pytest, unittest

**测试范围**:
- 算子输入输出正确性
- 边界条件处理
- 错误处理机制

**示例**:
```python
import pytest
import numpy as np
import tilelang as tl

def test_gemm_basic():
    """测试基础 GEMM 算子"""
    M, N, K = 128, 128, 128
    a = np.random.randn(M, K).astype(np.float16)
    b = np.random.randn(K, N).astype(np.float16)
    
    # 编译 GEMM 算子
    @tl.jit
    def gemm_kernel(a_shape, b_shape):
        a = tl.tensor(a_shape, tl.float16)
        b = tl.tensor(b_shape, tl.float16)
        c = tl.zeros((M, N), dtype=tl.float16)
        # ... GEMM 实现
        return c
    
    # 运行算子
    c = gemm_kernel((M, K), (K, N))
    
    # 与 NumPy 对比
    c_ref = np.matmul(a, b)
    np.testing.assert_allclose(c, c_ref, rtol=1e-3)

def test_gemm_edge_cases():
    """测试边界条件"""
    # 最小尺寸
    test_gemm_basic()
    
    # 非方阵
    M, N, K = 64, 128, 256
    # ... 测试代码
    
    # 奇数尺寸
    M, N, K = 127, 129, 131
    # ... 测试代码
```

### 2. 集成测试

**目的**: 验证多个算子协同工作

**工具**: pytest, pytest-benchmark

**测试范围**:
- 算子组合的正确性
- 数据流正确性
- 内存管理

**示例**:
```python
def test_attention_pipeline():
    """测试完整的 Attention pipeline"""
    batch_size, seq_len, hidden_dim = 2, 128, 768
    
    # 准备输入
    q = np.random.randn(batch_size, seq_len, hidden_dim).astype(np.float16)
    k = np.random.randn(batch_size, seq_len, hidden_dim).astype(np.float16)
    v = np.random.randn(batch_size, seq_len, hidden_dim).astype(np.float16)
    
    # 运行完整 pipeline
    @tl.jit
    def flash_attention(q_shape, k_shape, v_shape):
        # QKV 投影
        # Softmax
        # 加权求和
        # ... 完整实现
        return output
    
    output = flash_attention(q.shape, k.shape, v.shape)
    
    # 验证输出形状
    assert output.shape == (batch_size, seq_len, hidden_dim)
    
    # 验证数值范围
    assert np.all(np.isfinite(output))
```

### 3. 性能测试

**目的**: 验证算子性能满足要求

**工具**: pytest-benchmark, nsight

**测试范围**:
- 执行时间
- 内存使用
- 吞吐量

**示例**:
```python
import pytest

def test_gemm_performance(benchmark):
    """测试 GEMM 性能"""
    M, N, K = 1024, 1024, 1024
    a = np.random.randn(M, K).astype(np.float16)
    b = np.random.randn(K, N).astype(np.float16)
    
    @tl.jit
    def gemm_kernel(a_shape, b_shape):
        # ... GEMM 实现
        return c
    
    def run_gemm():
        return gemm_kernel((M, K), (K, N))
    
    # 运行基准测试
    result = benchmark(run_gemm)
    
    # 验证性能目标
    target_time = 0.001  # 1ms
    assert result.stats['mean'] < target_time

def test_flash_attention_throughput(benchmark):
    """测试 Flash Attention 吞吐量"""
    batch_size, seq_len, hidden_dim = 4, 1024, 768
    
    def run_attention():
        # ... 运行 Attention
        return output
    
    result = benchmark(run_attention)
    
    # 计算吞吐量 (tokens/s)
    throughput = batch_size * seq_len / result.stats['mean']
    print(f"Throughput: {throughput:.2f} tokens/s")
    
    # 验证吞吐量目标
    assert throughput > 100000  # 100k tokens/s
```

### 4. 正确性验证

**目的**: 使用参考实现验证结果

**策略**:
- 与 NumPy/PyTorch 结果对比
- 使用小规模输入验证
- 边界条件测试
- 随机数据多次测试

**示例**:
```python
def test_correctness_with_reference():
    """使用参考实现验证"""
    sizes = [
        (64, 64, 64),
        (128, 128, 128),
        (256, 256, 256),
    ]
    
    for M, N, K in sizes:
        # 生成测试数据
        a = np.random.randn(M, K).astype(np.float16)
        b = np.random.randn(K, N).astype(np.float16)
        
        # TileLang 实现
        c_tl = gemm_tilelang(a, b)
        
        # 参考实现 (NumPy)
        c_ref = np.matmul(a, b)
        
        # 验证
        c_tl_float32 = c_tl.astype(np.float32)
        c_ref_float32 = c_ref.astype(np.float32)
        
        # 计算相对误差
        error = np.abs(c_tl_float32 - c_ref_float32) / (np.abs(c_ref_float32) + 1e-6)
        max_error = np.max(error)
        
        print(f"M={M}, N={N}, K={K}, max_error={max_error:.6f}")
        assert max_error < 1e-3, f"Error too large: {max_error}"
```

## 测试数据

### 生成策略

#### 1. 随机数据

使用固定种子确保可重复：

```python
import numpy as np

np.random.seed(42)  # 固定种子
data = np.random.randn(128, 128).astype(np.float16)
```

#### 2. 边界数据

测试最小/最大尺寸和特殊值：

```python
# 最小尺寸
test_cases = [
    (1, 1, 1),
    (2, 2, 2),
    (4, 4, 4),
]

# 最大尺寸（受硬件限制）
)
test_cases = [
    (1024, 1024, 1024),
    (2048, 2048, 2048),
]

# 特殊值
test_cases = [
    np.zeros((128, 128)),      # 全零
    np.ones((128, 128)),       # 全一
    np.eye(128),              # 单位矩阵
    np.full((128, 128), 1e6), # 大值
    np.full((128, 128), -1e6), # 负大值
]
```

#### 3. 真实数据

从实际应用中采样：

```python
# 从真实模型中采样
def load_real_data():
    # 加载真实的权重或激活值
    weights = load_model_weights()
    activations = load_model_activations()
    return weights, activations
```

### 数据管理

```python
# 测试数据集
test_cases = [
    {"name": "small", "M": 64, "N": 64, "K": 64},
    {"name": "medium", "M": 128, "N": 128, "K": 128},
    {"name": "large", "M": 256, "N": 256, "K": 256},
    {"name": "batch", "batch": 4, "seq": 128, "hidden": 768},
]

@pytest.mark.parametrize("case", test_cases)
def test_with_parametrized_data(case):
    """参数化测试"""
    if "batch" in case:
        # 测试批处理
        pass
    else:
        # 测试单算子
        pass
```

## 测试框架配置

### pytest 配置

创建 `pytest.ini` 或 `pyproject.toml`：

```ini
[tool:pytest]
# 测试文件模式
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# 测试路径
testpaths = tests

# 输出选项
addopts = 
    -v
    --strict-markers
    --tb=short
    --cov=tilelang
    --cov-report=html
    --cov-report=term

# 标记
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    gpu: marks tests as requiring GPU
    ascend: marks tests as requiring Ascend NPU
```

### 测试组织

```
tests/
├── unit/                    # 单元测试
│   ├── test_gemm.py
│   ├── test_attention.py
│   └── test_elementwise.py
├── integration/             # 集成测试
│   ├── test_pipeline.py
│   └── test_model.py
├── performance/             # 性能测试
│   ├── test_benchmark.py
│   └── test_profiling.py
└── conftest.py            # pytest 配置
```

## 持续集成

### GitHub Actions 配置

创建 `.github/workflows/test.yml`：

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov pytest-benchmark
      
      - name: Run unit tests
        run: pytest tests/unit/ -v
      
      - name: Run integration tests
        run: pytest tests/integration/ -v
      
      - name: Run performance tests
        run: pytest tests/performance/ -v --benchmark-only
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

### GitLab CI 配置

创建 `.gitlab-ci.yml`：

```yaml
stages:
  - test
  - benchmark

test:unit:
  stage: test
  script:
    - pip install -r requirements.txt
    - pip install pytest pytest-cov
    - pytest tests/unit/ --cov=tilelang --cov-report=xml
  coverage: '/TOTAL.*\s+(\d+%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

test:performance:
  stage: benchmark
  script:
    - pip install -r requirements.txt
    - pip install pytest pytest-benchmark
    - pytest tests/performance/ --benchmark-json=benchmark.json
  artifacts:
    paths:
      - benchmark.json
```

## 调试测试

### 使用 tilelang-debug-helper

当测试失败时，使用调试 Skill：

```
用户: tests/test_gemm.py 中的 test_gemm_basic 失败了，帮我调试
# → AI 使用 tilelang-debug-helper 添加调试代码
```

### 常见问题

#### 问题 1: 精度不匹配

**症状**: `AssertionError: Arrays are not almost equal`

**原因**: 
- 数据类型不匹配
- 精度设置不当
- 数值范围溢出

**解决**:
```python
# 检查数据类型
assert a.dtype == np.float16

# 使用合适的精度
rtol = 1e-3 if dtype == np.float16 else 1e-6
np.testing.assert_allclose(actual, expected, rtol=rtol)
```

#### 问题 2: 形状错误

**症状**: `ValueError: shape mismatch`

**原因**: 
- 输入输出形状计算错误
- 批处理维度处理不当

**解决**:
```python
# 添加形状断言
assert a.shape == (M, K), f"Expected shape ({M}, {K}), got {a.shape}"
assert b.shape == (K, N), f"Expected shape ({K}, {N}), got {b.shape}"

# 验证输出形状
assert output.shape == (M, N), f"Expected output shape ({M}, {N}), got {output.shape}"
```

#### 问题 3: 内存错误

**症状**: `Segmentation fault`, `Bus error`

**原因**: 
- 内存分配不足
- 越界访问
- 内存未初始化

**解决**:
```python
# 使用调试模式
import os
os.environ['TL_DEBUG'] = '1'

# 添加边界检查
assert M > 0 and N > 0 and K > 0

# 检查内存大小
required_memory = M * N * K * 2  # float16 = 2 bytes
assert required_memory < max_memory
```

#### 问题 4: 性能下降

**症状**: 测试超时或性能指标不达标

**原因**: 
- 算法实现低效
- 内存访问模式不佳
- 缺少优化

**解决**:
```python
# 使用性能分析工具
import cProfile

profiler = cProfile.Profile()
profiler.enable()

# 运行算子
result = kernel(...)

profiler.disable()
profiler.print_stats(sort='cumulative')

# 检查热点函数
```

## 测试最佳实践

### 1. 测试隔离

每个测试应该独立运行，不依赖其他测试：

```python
# ❌好：依赖全局状态
global_data = None

def test_setup():
    global global_data
    global_data = prepare_data()

def test_use():
    assert global_data is not None

# ✅好：每个测试独立
def test_with_fixture():
    data = prepare_data()
    assert data is not None
```

### 2. 使用 fixtures

使用 pytest fixtures 复用测试代码：

```python
@pytest.fixture
def gemm_data():
    """GEMM 测试数据 fixture"""
    M, N, K = 128, 128, 128
    a = np.random.randn(M, K).astype(np.float16)
    b = np.random.randn(K, N).astype(np.float16)
    return a, b, M, N, K

def test_gemm_with_fixture(gemm_data):
    a, b, M, N, K = gemm_data
    # ... 测试代码
```

### 3. 参数化测试

使用参数化测试覆盖多种情况：

```python
@pytest.mark.parametrize("M,N,K", [
    (64, 64, 64),
    (128, 128, 128),
    (256, 256, 256),
])
def test_gemm_sizes(M, N, K):
    """测试不同尺寸"""
    # ... 测试代码
```

### 4. 测试覆盖率

确保测试覆盖关键代码路径：

```bash
# 运行测试并生成覆盖率报告
pytest --cov=tilelang --cov-report=html

# 查看覆盖率报告
open htmlcov/index.html
```

### 5. 持续改进

定期审查和改进测试：

- 添加新的测试用例
- 移除重复的测试
- 优化慢速测试
- 更新测试文档

## 测试报告

### 生成测试报告

```bash
# 生成 HTML 报告
pytest --html=report.html --self-contained-html

# 生成 JUnit XML 报告（用于 CI）
pytest --junitxml=report.xml
```

### 性能报告

```bash
# 生成性能报告
pytest tests/performance/ --benchmark-json=benchmark.json

# 比较性能
pytest tests/performance/ --benchmark-compare=baseline.json
```

## 更多信息

- [pytest 文档](https://docs.pytest.org/)
- [pytest-benchmark 文档](https://pytest-benchmark.readthedocs.io/)
- [Python 测试最佳实践](https://docs.python-guide.org/writing/tests/)
