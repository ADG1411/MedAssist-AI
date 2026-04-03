from duckduckgo_search import DDGS
import logging

logger = logging.getLogger(__name__)

def search_web(query: str, max_results: int = 4) -> str:
    """
    Perform a web search using duckduckgo and return a combined text of result snippets.
    """
    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=max_results))
            
        if not results:
            return "No internet search results found."
            
        formatted_snippets = []
        for index, result in enumerate(results):
            snippet = result.get('body', result.get('title', ''))
            href = result.get('href', 'unknown source')
            formatted_snippets.append(f"Source {index + 1} ({href}): {snippet}")
            
        return "\n\n".join(formatted_snippets)
    except Exception as e:
        logger.error(f"Error fetching data from internet: {e}")
        return f"Internet search failed. Error: {str(e)}"
