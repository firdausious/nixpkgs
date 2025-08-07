#!/usr/bin/env python3
"""
Simple AI Development Assistant
Language-agnostic code analysis and generation tool
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any
import argparse

# LangChain imports
try:
    from langchain_core.messages import HumanMessage, SystemMessage
    from langchain_openai import ChatOpenAI
    from langchain_anthropic import ChatAnthropic
    
    # Try to import langchain-ollama, fallback to manual HTTP if not available
    try:
        from langchain_ollama import ChatOllama
        HAS_LANGCHAIN_OLLAMA = True
    except ImportError:
        HAS_LANGCHAIN_OLLAMA = False
        print("Note: langchain-ollama not available. Install with: pip install langchain-ollama")
        print("Falling back to HTTP requests for Ollama.")
        
except ImportError as e:
    print(f"Error: LangChain not installed. {e}")
    print("Run: pip install langchain langchain-openai langchain-anthropic")
    sys.exit(1)

class SimpleAI:
    """Simple AI assistant for code development"""
    
    def __init__(self):
        # Use centralized configuration from environment variables set by Nix
        ai_config_dir = os.environ.get("AI_CONFIG_DIR", str(Path.home() / ".config" / "dev-ai"))
        ai_workspace = os.environ.get("AI_WORKSPACE", str(Path.home() / "dev-ai"))
        
        self.config_dir = Path(ai_config_dir)
        self.workspace = Path(ai_workspace)
        self.config = self._load_config()
        self.llm = self._init_llm()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load simple configuration"""
        config_file = self.config_dir / "config.json"
        # Use environment variables from Nix configuration for defaults
        default_config = {
            "model": os.environ.get("AI_MODEL", "llama3.1:8b"),
            "provider": os.environ.get("AI_PROVIDER", "ollama"),
            "ollama_url": "http://127.0.0.1:11434",
            "temperature": 0.1
        }
        
        if config_file.exists():
            try:
                with open(config_file) as f:
                    return {**default_config, **json.load(f)}
            except:
                pass
        
        # Create config directory and file
        self.config_dir.mkdir(parents=True, exist_ok=True)
        with open(config_file, 'w') as f:
            json.dump(default_config, f, indent=2)
        
        return default_config
    
    def _init_llm(self):
        """Initialize LLM based on configuration"""
        provider = self.config.get("provider", "ollama")
        model = self.config.get("model", "llama3.1:8b")
        
        try:
            if provider == "ollama":
                if not HAS_LANGCHAIN_OLLAMA:
                    print("Warning: langchain-ollama not available.")
                    print("Please install it with: pip install langchain-ollama")
                    print("For now, switching to manual HTTP implementation...")
                    return self._create_manual_ollama_client()
                return ChatOllama(
                    model=model,
                    base_url=self.config.get("ollama_url", "http://127.0.0.1:11434"),
                    temperature=self.config.get("temperature", 0.1)
                )
            elif provider == "openai":
                return ChatOpenAI(
                    model=model,
                    temperature=self.config.get("temperature", 0.1)
                )
            elif provider == "anthropic":
                return ChatAnthropic(
                    model=model,
                    temperature=self.config.get("temperature", 0.1)
                )
        except Exception as e:
            print(f"Error initializing {provider}: {e}")
            print("Make sure the service is running and accessible")
            sys.exit(1)
    
    def _create_manual_ollama_client(self):
        """Create a manual HTTP client for Ollama when langchain-ollama is not available"""
        import requests
        
        class ManualOllamaClient:
            def __init__(self, base_url, model, temperature):
                self.base_url = base_url
                self.model = model
                self.temperature = temperature
            
            def invoke(self, messages):
                # Convert messages to Ollama format
                prompt = ""
                for msg in messages:
                    if hasattr(msg, 'content'):
                        if msg.__class__.__name__ == 'SystemMessage':
                            prompt += f"System: {msg.content}\n\n"
                        elif msg.__class__.__name__ == 'HumanMessage':
                            prompt += f"User: {msg.content}\n\n"
                
                # Make request to Ollama
                try:
                    response = requests.post(
                        f"{self.base_url}/api/generate",
                        json={
                            "model": self.model,
                            "prompt": prompt,
                            "stream": False,
                            "options": {
                                "temperature": self.temperature
                            }
                        },
                        timeout=120
                    )
                    response.raise_for_status()
                    result = response.json()
                    
                    # Create a simple response object
                    class SimpleResponse:
                        def __init__(self, content):
                            self.content = content
                    
                    return SimpleResponse(result.get("response", "No response from Ollama"))
                    
                except requests.exceptions.RequestException as e:
                    print(f"Error connecting to Ollama: {e}")
                    print("Make sure Ollama is running: llm-start")
                    sys.exit(1)
        
        return ManualOllamaClient(
            self.config.get("ollama_url", "http://127.0.0.1:11434"),
            self.config.get("model", "llama3.1:8b"),
            self.config.get("temperature", 0.1)
        )
    
    def _detect_language(self, file_path: str) -> str:
        """Detect programming language from file extension"""
        ext = Path(file_path).suffix.lower()
        lang_map = {
            '.py': 'Python',
            '.js': 'JavaScript',
            '.ts': 'TypeScript',
            '.go': 'Go',
            '.rs': 'Rust',
            '.php': 'PHP',
            '.rb': 'Ruby',
            '.java': 'Java',
            '.c': 'C',
            '.cpp': 'C++',
            '.cs': 'C#',
            '.sh': 'Shell',
            '.sql': 'SQL',
            '.html': 'HTML',
            '.css': 'CSS',
            '.json': 'JSON',
            '.yaml': 'YAML',
            '.yml': 'YAML',
            '.xml': 'XML',
            '.md': 'Markdown'
        }
        return lang_map.get(ext, 'Unknown')
    
    def _get_git_context(self, path: str = ".") -> str:
        """Get git context for the project"""
        try:
            # Get current branch
            branch = subprocess.check_output(
                ["git", "branch", "--show-current"], 
                cwd=path, 
                text=True
            ).strip()
            
            # Get recent commits
            commits = subprocess.check_output(
                ["git", "log", "--oneline", "-5"], 
                cwd=path, 
                text=True
            ).strip()
            
            # Get current status
            status = subprocess.check_output(
                ["git", "status", "--porcelain"], 
                cwd=path, 
                text=True
            ).strip()
            
            return f"Branch: {branch}\n\nRecent commits:\n{commits}\n\nCurrent status:\n{status}"
        except:
            return "No git repository found"
    
    def review_code(self, file_path: str) -> str:
        """Review code in a file"""
        if not Path(file_path).exists():
            return f"File not found: {file_path}"
        
        with open(file_path) as f:
            code = f.read()
        
        language = self._detect_language(file_path)
        git_context = self._get_git_context(str(Path(file_path).parent))
        
        system_prompt = f"""You are a senior software engineer reviewing {language} code.
Analyze the code for:
- Logic errors and bugs
- Security vulnerabilities
- Performance issues
- Best practices compliance
- Code style and readability
- Potential improvements

Be concise and actionable in your feedback."""

        user_prompt = f"""File: {file_path}
Language: {language}

Git Context:
{git_context}

Code to review:
```{language.lower()}
{code}
```

Please provide a detailed code review."""

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt)
        ]
        
        response = self.llm.invoke(messages)
        return response.content
    
    def generate_code(self, description: str, language: Optional[str] = None, context: Optional[str] = None) -> str:
        """Generate code based on description"""
        if not language:
            # Try to detect from context or default to current directory
            if context and Path(context).is_dir():
                # Check for common files to detect language
                for file in Path(context).glob("*"):
                    if file.suffix:
                        language = self._detect_language(str(file))
                        if language != 'Unknown':
                            break
            
            if not language or language == 'Unknown':
                language = "Python"  # Default
        
        git_context = self._get_git_context(context or ".")
        
        system_prompt = f"""You are an expert {language} developer.
Generate high-quality, production-ready code that:
- Follows {language} best practices and conventions
- Is well-structured and maintainable
- Includes proper error handling
- Has clear comments explaining complex logic
- Uses appropriate design patterns
- Is secure and performant"""

        user_prompt = f"""Generate {language} code for: {description}

Git Context:
{git_context}

Please provide:
1. Complete, working code
2. Brief explanation of the approach
3. Usage example if applicable"""

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt)
        ]
        
        response = self.llm.invoke(messages)
        return response.content
    
    def analyze_project(self, path: str = ".") -> str:
        """Analyze project structure and provide insights"""
        project_path = Path(path).resolve()
        
        if not project_path.exists():
            return f"Path not found: {path}"
        
        # Get project structure
        files = []
        for file_path in project_path.rglob("*"):
            if file_path.is_file() and not any(part.startswith('.') for part in file_path.parts):
                relative_path = file_path.relative_to(project_path)
                if len(str(relative_path)) < 100:  # Avoid very long paths
                    files.append(str(relative_path))
        
        # Limit files shown
        files = sorted(files)[:50]
        
        git_context = self._get_git_context(str(project_path))
        
        system_prompt = """You are a software architect analyzing a project.
Provide insights on:
- Project structure and organization
- Technology stack and dependencies
- Potential improvements
- Security considerations
- Scalability aspects
- Code quality observations"""

        user_prompt = f"""Analyze this project:

Path: {project_path}

Git Context:
{git_context}

Project files (first 50):
{chr(10).join(files)}

Please provide a comprehensive project analysis."""

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt)
        ]
        
        response = self.llm.invoke(messages)
        return response.content
    
    def chat(self, message: str) -> str:
        """General chat with AI"""
        system_prompt = """You are a helpful software development assistant.
You can help with:
- Code review and debugging
- Architecture decisions
- Best practices
- Technology recommendations
- Problem solving

Be concise and practical in your responses."""

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=message)
        ]
        
        response = self.llm.invoke(messages)
        return response.content

def main():
    parser = argparse.ArgumentParser(description="Simple AI Development Assistant")
    parser.add_argument("command", choices=["review", "generate", "analyze", "chat"], help="Command to run")
    parser.add_argument("target", nargs="?", help="File path or description")
    parser.add_argument("--language", "-l", help="Programming language for generation")
    parser.add_argument("--context", "-c", help="Context path for analysis")
    
    args = parser.parse_args()
    
    ai = SimpleAI()
    
    try:
        if args.command == "review":
            if not args.target:
                print("Please provide a file path to review")
                sys.exit(1)
            result = ai.review_code(args.target)
        
        elif args.command == "generate":
            if not args.target:
                print("Please provide a description for code generation")
                sys.exit(1)
            result = ai.generate_code(args.target, args.language, args.context)
        
        elif args.command == "analyze":
            path = args.target or "."
            result = ai.analyze_project(path)
        
        elif args.command == "chat":
            if not args.target:
                print("Please provide a message")
                sys.exit(1)
            result = ai.chat(args.target)
        
        print(result)
        
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
